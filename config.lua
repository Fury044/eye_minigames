Config = {}

-- Allow ESC to cancel a game. Per-call `allowCancel` overrides this.
Config.AllowCancelByDefault = true

-- Register /mg, /mglist, /mgrandom, /mgall test commands.
-- Set to false on a live/production server.
Config.EnableTestCommands = true

-- Sound effects (synthesized, no audio files). Per-call `sound`/`volume` override.
Config.Sound = true        -- master on/off
Config.Volume = 0.5        -- 0.0 - 1.0

-- Default difficulty (1-5) and per-game options. Override per call.
Config.Defaults = {
    livewire    = { difficulty = 2 },
    flatline    = { difficulty = 2, rounds = 3 },
    deadcalm    = { difficulty = 2, shots = 3 },
    ghostsignal = { difficulty = 2 },
    steadydose  = { difficulty = 2 },
    cuttheright = { difficulty = 2 },
    vaultspin   = { difficulty = 2, tumblers = 3 },
    bluff       = { difficulty = 2, hands = 3 },
    decrypt     = { difficulty = 2 },
    gaslight    = { difficulty = 2 },

    -- advanced pack (inspired by well-known game mechanics)
    overflow     = { difficulty = 2 },
    breachmatrix = { difficulty = 2 },
    daemonrun    = { difficulty = 2 },
    pulse        = { difficulty = 2 },
    hottrace     = { difficulty = 2 },
    cascade      = { difficulty = 2 },
    lightsout    = { difficulty = 2 },
    slidepuzzle  = { difficulty = 2 },

    -- AAA-inspired pack
    resonance    = { difficulty = 2 },
    intrusion    = { difficulty = 2 },
    override     = { difficulty = 2 },
    animus       = { difficulty = 2 },
    eaglevision  = { difficulty = 2 },
    parry        = { difficulty = 2 },
    constellation = { difficulty = 2 },
    archery      = { difficulty = 2 },

    -- essentials (universal, fit any script)
    skillcheck   = { difficulty = 2, rounds = 3 },
    lockpick     = { difficulty = 2 },
    keypad       = { difficulty = 2 },
    quicktime    = { difficulty = 2 },
    mash         = { difficulty = 2 },
    reaction     = { difficulty = 2 },
    stacker      = { difficulty = 2 },
    targets      = { difficulty = 2 },

    -- jobs (job-specific)
    fishing      = { difficulty = 2 },
    mining       = { difficulty = 2 },
    cooking      = { difficulty = 2 },
    welding      = { difficulty = 2 },
    harvest      = { difficulty = 2 },
    drilling     = { difficulty = 2 },
    locksmith    = { difficulty = 2 },
    hotwire      = { difficulty = 2 },
    crafting     = { difficulty = 2 },
    forge        = { difficulty = 2 },
    diving       = { difficulty = 2 },

    -- crime & heist
    tripwire     = { difficulty = 2 },
    pickpocket   = { difficulty = 2 },
    getaway      = { difficulty = 2 },
    cashcount    = { difficulty = 2 },
    counterfeit  = { difficulty = 2 },
    chopshop     = { difficulty = 2 },

    -- jobs & trades (extended)
    lugnuts      = { difficulty = 2 },
    paintspray   = { difficulty = 2 },
    crane        = { difficulty = 2 },

    -- medical & rescue
    suture       = { difficulty = 2 },
    bonepin      = { difficulty = 2 },
    vitals       = { difficulty = 2 },

    -- heist
    thermite     = { difficulty = 2 },
    lasergrid    = { difficulty = 2 },
    vaultdrill   = { difficulty = 2 },
    jammer       = { difficulty = 2 },
    dataheist    = { difficulty = 2 },

    -- mechanic (sorting / moving things around)
    partsort     = { difficulty = 2 },
    toolbox      = { difficulty = 2 },
    packing      = { difficulty = 2 },
    beltsort     = { difficulty = 2 },

    -- police & forensics
    fingerprint  = { difficulty = 2 },
    breathalyzer = { difficulty = 2 },

    -- drugs & chemistry
    titration    = { difficulty = 2 },
    pillpress    = { difficulty = 2 }
}

-- Freeze the player while a game is open.
Config.FreezePlayer = false
