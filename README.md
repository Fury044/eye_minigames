# Ay-eye Minigames

A **standalone, framework-agnostic** pack of 29 cinematic skill-check minigames
for FiveM, with one clean export API. No ESX, QBCore, QBox, or ox_lib required.
Drop it in, call it from any script, get a `true`/`false` back.

# Preview https://eye-minigames.vercel.app/
---

## The games (29 total)

### Essentials (8 — the everyday workhorses, fit any script)

| id | name | mechanic | good for |
|----|------|----------|----------|
| `skillcheck` | Skill Check | sweep a marker into the zone (multi-round) | the universal one — any job/crime action |
| `lockpick` | Lockpick | rotate pick to each hidden sweet spot | doors, vehicles, safes, lockers |
| `keypad` | Keypad | deduce a hidden PIN from ●/○ feedback | doors, safes, alarms, terminals |
| `quicktime` | Quicktime | press a key sequence before each timer | struggles, repairs, chases, QTEs |
| `mash` | Mash | spam SPACE to fill a draining bar | break free, CPR, prying, pushing |
| `reaction` | Reaction | wait for green, tap fast (no early starts) | reflex gates, quickdraw, sobriety |
| `stacker` | Stacker | drop sliding blocks to stack a tower | loading, assembling, packing |
| `targets` | Targets | click pop-up targets, dodge red decoys | aim gates, fast interactions |

### Core (10)

| id | name | mechanic | good for |
|----|------|----------|----------|
| `livewire` | Live Wire | drag-match colored wires | electrician, panel hacks, fuse boxes |
| `flatline` | Flatline | defib rhythm timing (SPACE in green zone) | EMS, revives |
| `deadcalm` | Dead Calm | sniper breath control (hold SPACE, click) | hits, hunting, ranges |
| `ghostsignal` | Ghost Signal | tune frequency + phase to a hidden wave | surveillance, jamming, radios |
| `steadydose` | Steady Dose | keep needle in a moving band (mouse) | medic, drugs, lab work |
| `cuttheright` | Cut The Right One | read clue, cut the correct wire | bomb defusal, traps |
| `vaultspin` | Vault Spin | analog combination dial (drag) | safes, vaults |
| `bluff` | Bluff | read NPC tells, call or fold | interrogation, deals, poker |
| `decrypt` | Decrypt | type streaming code tokens | hacking, terminals |
| `gaslight` | Gaslight | flash-memory recall | witness, recon, observation |

### Advanced (6 — inspired by well-known game mechanics)

| id | name | mechanic | inspired by | good for |
|----|------|----------|-------------|----------|
| `overflow` | Overflow | rotate pipe tiles to connect source→drain | Pipe Dream / BioShock | plumbing, gas, fluid systems |
| `breachmatrix` | Breach Matrix | hex sequence injection, row/col picks | Cyberpunk Breach Protocol | advanced hacking, terminals |
| `daemonrun` | Daemon Run | maze data-grab while dodging a trace | Pac-Man-style hacks | data heists, ICE evasion |
| `pulse` | Pulse | 4-lane rhythm note hitting (D F J K) | Guitar Hero / rhythm | DJ, music, timing-heavy jobs |
| `hottrace` | Hot Trace | drag a probe through a corridor, no walls | Operation / wire-loop | surgery, delicate wiring, defusal |
| `cascade` | Cascade | escalating Simon-says pattern memory | Simon / Bop It | keypads, memory locks |

### AAA-Inspired (5 — premium signature mechanics)

| id | name | mechanic | inspired by | good for |
|----|------|----------|-------------|----------|
| `resonance` | Resonance | tune sine sliders so your wave matches a target (one "inverts voltage") | Marvel's Spider-Man circuit puzzles | calibration, lab hacks, repairs |
| `intrusion` | Intrusion | hop the signal through a node network, dodge monitored (red) nodes | Watch Dogs camera/ctOS hopping | advanced hacking, CCTV, infiltration |
| `override` | Override | lock spinning concentric rings at the top notch before corruption fills | Horizon Zero Dawn override | machine/drone takeover, control hacks |
| `animus` | Animus | rotate concentric rings to align all key segments to one spoke | Assassin's Creed animus/glyph | ancient locks, sync points, relics |
| `eaglevision` | Eagle Vision | memorize a target signature, then click every match among decoys | AC eagle vision / spider-sense | recon, target ID, surveillance |

---

## Install

1. Drop the `eye_minigames` folder into your `resources`.
2. Add to `server.cfg`:
   ```
   ensure eye_minigames
   ```
3. (Optional) rename the folder — just keep it consistent with the
   `ensure` line. The export name follows the folder name.

No database, no dependencies.

---

## Usage

### Blocking (recommended — runs inside a thread)

```lua
CreateThread(function()
    local ok = exports.eye_minigames:Play('vaultspin', {
        difficulty = 3,                 -- 1 (easy) .. 5 (brutal)
        tumblers   = 4,                 -- per-game option (see table below)
        theme      = { accent = '#ff8a00' }
    })

    if ok then
        print('cracked the safe!')
        -- TriggerServerEvent('myheist:vaultOpen')
    else
        print('failed')
    end
end)
```

### Non-blocking (callback)

```lua
exports.eye_minigames:Start('flatline', { difficulty = 4 }, function(ok)
    if ok then
        -- revive logic
    end
end)
```

---

## Options

Every call takes an options table. All fields optional.

| field | type | default | notes |
|-------|------|---------|-------|
| `difficulty` | number 1–5 | per-game (config.lua) | scales speed/size/timer |
| `theme` | table | global theme | `{ accent, danger, success, bg }` hex strings |
| `allowCancel` | bool | `Config.AllowCancelByDefault` | ESC / Backspace to bail |

Per-game extras:

| game | extra option | default |
|------|--------------|---------|
| `skillcheck` | `rounds` | 2 + diff/1.5 |
| `flatline` | `rounds` (shocks needed) | 3 |
| `deadcalm` | `shots` | 3 |
| `vaultspin` | `tumblers` | 2 + diff/2 |
| `bluff` | `hands` | 3 |

All advanced games are driven purely by `difficulty` (1–5) — no extra
options needed, though you can still pass `theme` and `allowCancel`.

---

## Theming per call

Match the minigame to the script that triggered it:

```lua
-- red, no-cancel bomb defusal
exports.eye_minigames:Play('cuttheright', {
    difficulty = 4,
    allowCancel = false,
    theme = { accent = '#ff3b5c' }
})
```

Global defaults live in `config.lua` → `Config.DefaultTheme`.

---

## Test in-game

Test commands are on by default (`Config.EnableTestCommands`). Turn the
flag off in `config.lua` for production.

```
/mg <id> [difficulty]   play one game, e.g. /mg lockpick 4
/mglist                 list every game id by category
/mgrandom [difficulty]  play a random game
/mgall [difficulty]     play every game back-to-back (QA sweep)
```

Results print to console and chat. The commands have chat autocomplete
suggestions.

---

## Notes

- Pure client-side skill checks. `server/main.lua` is a stub for your own
  anti-abuse hooks (rate-limiting etc.).
- Built on canvas + vanilla JS NUI. Zero external runtime deps.
- One game runs at a time; concurrent calls return `false` immediately.
