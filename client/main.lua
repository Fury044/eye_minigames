local isActive = false
local activeCb = nil

local function merge(a, b)
    local out = {}
    for k, v in pairs(a or {}) do out[k] = v end
    for k, v in pairs(b or {}) do
        if k == 'theme' and type(v) == 'table' then
            out.theme = out.theme or {}
            for tk, tv in pairs(v) do out.theme[tk] = tv end
        else
            out[k] = v
        end
    end
    return out
end

local function finish(success)
    if not isActive then return end
    isActive = false
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
    payload.theme = merge(Config.DefaultTheme, (opts and opts.theme) or {})
    if payload.allowCancel == nil then
        payload.allowCancel = Config.AllowCancelByDefault
    end
    if payload.sound == nil then payload.sound = Config.Sound end
    if payload.volume == nil then payload.volume = Config.Volume end

    isActive = true
    activeCb = cb

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

exports('Start', Start)
exports('Play', Play)

RegisterNUICallback('result', function(data, cb)
    finish(data and data.success)
    cb('ok')
end)

RegisterNUICallback('closed', function(_, cb)
    finish(false)
    cb('ok')
end)

if Config.EnableTestCommands then
    local categories = {
        essentials = { 'skillcheck', 'lockpick', 'keypad', 'quicktime', 'mash', 'reaction', 'stacker', 'targets' },
        core       = { 'livewire', 'flatline', 'deadcalm', 'ghostsignal', 'steadydose', 'cuttheright', 'vaultspin', 'bluff', 'decrypt', 'gaslight' },
        advanced   = { 'overflow', 'breachmatrix', 'daemonrun', 'pulse', 'hottrace', 'cascade' },
        aaa        = { 'resonance', 'intrusion', 'override', 'animus', 'eaglevision' },
        jobs       = { 'fishing', 'mining', 'cooking', 'welding', 'harvest' }
    }
    local order = { 'essentials', 'core', 'advanced', 'aaa', 'jobs' }

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
            notify('usage: /mg <id> [1-5]   |   /mglist for all ids')
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
