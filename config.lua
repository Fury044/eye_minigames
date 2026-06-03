Config = {}

-- Default theme. Per-call `theme` overrides any of these.
Config.DefaultTheme = {
    accent  = '#00e0b8',
    danger  = '#ff3b5c',
    success = '#39d98a',
    bg      = '#0a0e14'
}

-- Allow ESC to cancel a game. Per-call `allowCancel` overrides this.
Config.AllowCancelByDefault = true

-- Register /mg, /mglist, /mgrandom, /mgall test commands.
-- Set to false on a live/production server.
Config.EnableTestCommands = true

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

    -- AAA-inspired pack
    resonance    = { difficulty = 2 },
    intrusion    = { difficulty = 2 },
    override     = { difficulty = 2 },
    animus       = { difficulty = 2 },
    eaglevision  = { difficulty = 2 },

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
    harvest      = { difficulty = 2 }
}

-- Freeze the player while a game is open.
Config.FreezePlayer = false
