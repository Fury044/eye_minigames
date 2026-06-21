local isActive = false
local activeCb = nil
local activeNonce = nil

-- Generate an unguessable per-session token. Used to reject forged NUI
-- result callbacks (e.g. someone POSTing {success=true} from devtools).
local nonceCounter = 0
local function makeNonce()
    nonceCounter = nonceCounter + 1
    local parts = {
        tostring(GetGameTimer()),
        tostring(math.random(100000, 999999)),
        tostring(math.random(100000, 999999)),
        tostring(nonceCounter)
    }
    return table.concat(parts, '-')
end

local function merge(a, b)
    local out = {}
    for k, v in pairs(a or {}) do out[k] = v end
    for k, v in pairs(b or {}) do out[k] = v end
    return out
end

local function finish(success)
    if not isActive then return end
    isActive = false
    activeNonce = nil
    SetNuiFocus(false, false)
    if Config.FreezePlayer then
        FreezeEntityPosition(PlayerPedId(), false)
    end
    local cb = activeCb
    activeCb = nil
    if cb then cb(success and true or false) end
end

local function Start(game, opts, cb)
    if isActive then
        if cb then cb(false) end
        return
    end
    game = string.lower(game or '')
    local defaults = Config.Defaults[game]
    if not defaults then
        print(('[eye_minigames] unknown game id: "%s"'):format(game))
        if cb then cb(false) end
        return
    end

    local payload = merge(defaults, opts)
    payload.game = game
    payload.theme = nil

    if payload.allowCancel == nil then
        payload.allowCancel = Config.AllowCancelByDefault
    end
    if payload.sound == nil then payload.sound = Config.Sound end
    if payload.volume == nil then payload.volume = Config.Volume end

    isActive = true
    activeCb = cb
    activeNonce = makeNonce()
    payload.nonce = activeNonce

    if Config.FreezePlayer then
        FreezeEntityPosition(PlayerPedId(), true)
    end

    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', payload = payload })
end

local function Play(game, opts)
    local done, result = false, false
    Start(game, opts, function(ok)
        result = ok
        done = true
    end)
    while not done do Wait(0) end
    return result
end

-- Play games back-to-back. Returns: success, completed, total
local function PlayChain(games, opts)
    opts = opts or {}
    local stopOnFail = opts.stopOnFail
    if stopOnFail == nil then stopOnFail = true end
    local total = #games
    local completed = 0

    for i = 1, total do
        local stage = games[i]
        local id, stageOpts
        if type(stage) == 'table' then
            id = stage.game or stage[1]
            stageOpts = merge(opts, stage)
            stageOpts.game = nil
        else
            id = stage
            stageOpts = merge(opts, {})
        end

        local ok = Play(id, stageOpts)
        if ok then
            completed = completed + 1
        elseif stopOnFail then
            return false, completed, total
        end
        if i < total then Wait(opts.failDelay or 250) end
    end

    return completed == total, completed, total
end

exports('Start', Start)
exports('Play', Play)
exports('PlayChain', PlayChain)

RegisterNUICallback('result', function(data, cb)
    cb('ok')
    -- Reject results that don't carry the active session token. This blocks
    -- forged callbacks (e.g. a POST sent from devtools) trying to fake a win.
    if not isActive then return end
    if not data or data.nonce ~= activeNonce then
        print('[eye_minigames] rejected result with invalid/missing token')
        return
    end
    finish(data.success)
end)

RegisterNUICallback('closed', function(data, cb)
    cb('ok')
    if not isActive then return end
    if not data or data.nonce ~= activeNonce then return end
    finish(false)
end)

if Config.EnableTestCommands then
    local categories = {
        essentials = { 'skillcheck', 'lockpick', 'keypad', 'quicktime', 'mash', 'reaction', 'stacker', 'targets' },
        core       = { 'livewire', 'flatline', 'deadcalm', 'ghostsignal', 'steadydose', 'cuttheright', 'vaultspin', 'bluff', 'decrypt', 'gaslight' },
        advanced   = { 'overflow', 'breachmatrix', 'daemonrun', 'pulse', 'hottrace', 'cascade' },
        aaa        = { 'resonance', 'intrusion', 'override', 'animus', 'eaglevision' },
        jobs       = { 'fishing', 'mining', 'cooking', 'welding', 'harvest', 'drilling', 'locksmith', 'hotwire', 'crafting', 'lugnuts', 'paintspray', 'crane' },
        mechanic   = { 'partsort', 'toolbox', 'packing', 'beltsort' },
        crime      = { 'tripwire', 'pickpocket', 'getaway' },
        medical    = { 'suture', 'bonepin', 'vitals' },
        police     = { 'fingerprint', 'breathalyzer' },
        chemistry  = { 'titration', 'pillpress' },
        heist      = { 'thermite', 'lasergrid', 'vaultdrill', 'jammer', 'dataheist' }
    }
    local order = { 'essentials', 'core', 'advanced', 'aaa', 'jobs', 'mechanic', 'crime', 'medical', 'police', 'chemistry', 'heist' }

    local function allIds()
        local t = {}
        for _, cat in ipairs(order) do
            for _, id in ipairs(categories[cat]) do t[#t + 1] = id end
        end
        return t
    end

    local function notify(msg)
        if GetResourceState('chat') == 'started' then
            TriggerEvent('chat:addMessage', { args = { '^3[minigames]^7 ' .. msg } })
        end
        print('[eye_minigames] ' .. msg)
    end

    -- /mg <id> [difficulty]  -> play one game
    RegisterCommand('mg', function(_, args)
        local id = args[1]
        local diff = tonumber(args[2]) or 2
        if not id then
            notify('usage: /mg <id> [1-5]   |   /mglist for ids')
            return
        end
        if not Config.Defaults[string.lower(id)] then
            notify('unknown id "' .. id .. '" — try /mglist')
            return
        end
        CreateThread(function()
            local ok = Play(id, { difficulty = diff })
            notify(('%s (diff %d) -> %s'):format(id, diff, ok and '^2SUCCESS' or '^1FAIL'))
        end)
    end, false)

    -- /mglist -> print every game id by category
    RegisterCommand('mglist', function()
        for _, cat in ipairs(order) do
            notify(('^5%s:^7 %s'):format(cat:upper(), table.concat(categories[cat], ', ')))
        end
    end, false)

    -- /mgchain <id1> <id2> ... [difficulty as last arg if number] -> play a sequence
    RegisterCommand('mgchain', function(_, args)
        if #args == 0 then
            notify('usage: /mgchain <id1> <id2> <id3> ...  (e.g. /mgchain lockpick breachmatrix override)')
            return
        end
        local diff = 2
        local ids = {}
        for _, a in ipairs(args) do
            local n = tonumber(a)
            if n then diff = n
            elseif Config.Defaults[string.lower(a)] then ids[#ids + 1] = a
            else notify('skipping unknown id "' .. a .. '"') end
        end
        if #ids == 0 then notify('no valid game ids given') return end
        CreateThread(function()
            notify(('chain start: %s (diff %d)'):format(table.concat(ids, ' -> '), diff))
            local ok, done, total = PlayChain(ids, { difficulty = diff })
            notify(('chain %s — %d/%d completed'):format(ok and '^2COMPLETE' or '^1FAILED', done, total))
        end)
    end, false)

    -- /mgrandom [difficulty] -> play a random game
    RegisterCommand('mgrandom', function(_, args)
        local diff = tonumber(args[1]) or 2
        local ids = allIds()
        local id = ids[math.random(#ids)]
        CreateThread(function()
            local ok = Play(id, { difficulty = diff })
            notify(('random: %s (diff %d) -> %s'):format(id, diff, ok and '^2SUCCESS' or '^1FAIL'))
        end)
    end, false)

    -- /mgall [difficulty] -> play every game back-to-back (QA sweep)
    RegisterCommand('mgall', function(_, args)
        local diff = tonumber(args[1]) or 2
        local ids = allIds()
        CreateThread(function()
            local pass = 0
            for i, id in ipairs(ids) do
                notify(('(%d/%d) %s'):format(i, #ids, id))
                local ok = Play(id, { difficulty = diff })
                if ok then pass = pass + 1 end
                Wait(400)
            end
            notify(('sweep done: ^2%d^7/%d passed'):format(pass, #ids))
        end)
    end, false)

    -- chat autocomplete suggestions
    CreateThread(function()
        Wait(1000)
        if GetResourceState('chat') ~= 'started' then return end
        TriggerEvent('chat:addSuggestion', '/mg', 'Play a minigame', {
            { name = 'id', help = 'game id (see /mglist)' },
            { name = 'difficulty', help = '1-5 (optional, default 2)' }
        })
        TriggerEvent('chat:addSuggestion', '/mglist', 'List all minigame ids')
        TriggerEvent('chat:addSuggestion', '/mgrandom', 'Play a random minigame', {
            { name = 'difficulty', help = '1-5 (optional)' }
        })
        TriggerEvent('chat:addSuggestion', '/mgall', 'Play every minigame in sequence (QA)', {
            { name = 'difficulty', help = '1-5 (optional)' }
        })
    end)
end
