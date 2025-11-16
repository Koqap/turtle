# SmartMiner V2 - Persistent Storage & Auto-Recovery

## New Features

### 1. **Persistent Home Location Storage**
- Saves home/chest location to `home_location.txt`
- Remembers position even after turtle restart/crash
- Stores: X, Y, Z coordinates + facing direction

### 2. **Auto-Recovery from Saved Location**
- On startup, prompts to use saved location (Y/n)
- Skip chest setup if location already saved
- Automatically navigate back if restarted mid-mining

### 3. **Emergency Return Home**
- If scanner stops responding (6+ idle cycles)
- Automatically returns to base
- Deposits items and waits for scanner

### 4. **Auto-Startup Script**
- `startup.lua` - Runs automatically on turtle boot
- Checks for saved home location
- Auto-starts miner if home is saved
- 3-second countdown (Ctrl+T to cancel)

## Usage

### First Time Setup:
```bash
miner_v2
```
- Set up chest location
- Position is automatically saved
- Mining begins

### After Restart/Crash:
```bash
miner_v2
```
OR just reboot turtle (auto-starts)

- Loads saved home location
- Asks: "Use saved location? (Y/n)"
- Press Enter to continue from saved location

### Installing Auto-Startup:
1. Upload `startup.lua` to turtle
2. Reboot turtle
3. Automatically starts mining!

## File Structure

```
/turtle/
  ├── miner_v2           # Main miner program
  ├── startup.lua        # Auto-start on boot
  └── home_location.txt  # Saved home (auto-created)
```

## How It Works

### Home Location File (`home_location.txt`):
```lua
{
  x = 150,
  y = 65,
  z = -200,
  facing = 1  -- 0=north, 1=east, 2=south, 3=west
}
```

### Emergency Return Logic:
```
Idle Count >= 3 → Request new scan
Idle Count >= 6 → Return home & wait
```

## Benefits

✅ **No Re-Setup** - Restart turtle anytime without reconfiguring
✅ **Crash Recovery** - Turtle remembers home if it crashes
✅ **Scanner Disconnect** - Auto-returns home if scanner offline
✅ **Auto-Start** - Boots into mining mode automatically
✅ **Persistent** - Survives world restart/server restart

## Commands

**Reset home location:**
```bash
delete home_location.txt
miner_v2
```

**Disable auto-startup:**
```bash
delete startup.lua
```

**Check saved location:**
```bash
edit home_location.txt
```

## Status Messages

✓ Home location saved
✓ Found saved home location  
✓ Using saved home location
⚠ WARNING: Scanner not responding!
⚠ Returning to home base...
