# SmartMiner Auto-Start Guide

## ✅ What Changed

**OLD behavior:**
```
1. Turtle boots
2. Asks: "Use saved location? (Y/n)"
3. Wait for user input
4. Then start mining
```

**NEW behavior:**
```
1. Turtle boots
2. Auto-loads saved home
3. Immediately starts mining!
```

---

## 🚀 How It Works Now

### **First Time Setup (No saved home):**

```bash
# On turtle:
miner_v2
```

**What happens:**
```
═══════════════════════════════════
  SMARTMINER TURTLE V2
═══════════════════════════════════
Turtle ID: 3
Computer ID: 3

FIRST TIME SETUP

Place chest BEHIND turtle
(Turtle should face AWAY from chest)

Press ENTER when ready...
[Press Enter]

Getting home position...
✓ Home: 150, 65, -200

Verifying chest...
✓ Chest detected!

Detecting facing direction...
✓ Facing: north
✓ Home saved: 150,65,-200
✓ Setup complete
═══════════════════════════════════

Testing connection to computer...
✓ Connected to computer #3
Starting mining operations...
```

---

### **After Restart (Has saved home):**

```bash
# Just reboot:
reboot

# OR run manually:
miner_v2
```

**What happens:**
```
═══════════════════════════════════
  SMARTMINER TURTLE V2
═══════════════════════════════════
Turtle ID: 3
Computer ID: 3

✓ Loaded home: 150, 65, -200
✓ Facing: north
✓ Ready to mine!

(To reset home: delete home_location.txt)
✓ Setup complete
═══════════════════════════════════

Testing connection to computer...
✓ Connected to computer #3
Starting mining operations...
```

**No prompts! Immediately starts mining!** 🚀

---

## 🔄 Auto-Startup with startup.lua

### **If home_location.txt exists:**
```
═══════════════════════════════════
  SMARTMINER AUTO-STARTUP
═══════════════════════════════════
✓ Found saved home location
✓ Auto-starting miner in 3 seconds...

Press Ctrl+T to cancel

[3 seconds later: auto-starts miner_v2]
```

### **If no home_location.txt:**
```
═══════════════════════════════════
  SMARTMINER AUTO-STARTUP
═══════════════════════════════════
✗ No saved home location found

FIRST TIME SETUP:
  1. Place chest behind turtle
  2. Run: miner_v2
  3. Home will be saved automatically
  4. Next reboot = auto-start!

To start setup now, type: miner_v2

Startup complete.
```

---

## 📁 Saved Home File

**Location:** `/home_location.txt` (on turtle)

**Format:**
```lua
{
  x = 150,
  y = 65,
  z = -200,
  facing = 0  -- 0=north, 1=east, 2=south, 3=west
}
```

---

## 🔧 Reset Home Location

**Method 1: Delete file**
```bash
delete home_location.txt
miner_v2
```

**Method 2: Manual edit**
```bash
edit home_location.txt
# Edit coordinates
# Save and exit
miner_v2
```

**Method 3: From startup.lua message**
```
(To reset home: delete home_location.txt)
```

---

## 🎯 Use Cases

### **Scenario 1: Server Restart**
```
Server restarts → Turtle reboots
startup.lua runs → Detects saved home
Auto-starts miner → Resumes mining!
```

**Total downtime:** ~5 seconds ⚡

### **Scenario 2: Turtle Crash**
```
Turtle crashes/stops → Reboot turtle
Auto-loads home → Starts mining immediately
No re-setup needed!
```

### **Scenario 3: Multiple Turtles**
```
Setup Turtle #1 → Saves home
Copy home_location.txt to other turtles
All turtles share same base!
```

### **Scenario 4: Moving Base**
```
Delete home_location.txt
Move turtle to new location
Place new chest
Run miner_v2 → New home saved!
```

---

## ⚡ Quick Reference

### **Files:**
- `/miner_v2` - Main program
- `/startup.lua` - Auto-boot script  
- `/home_location.txt` - Saved home (auto-created)

### **Commands:**
| Command | Action |
|---------|--------|
| `miner_v2` | Start miner (auto-loads home if exists) |
| `reboot` | Restart turtle (auto-starts if startup.lua present) |
| `delete home_location.txt` | Reset home location |
| `edit home_location.txt` | View/edit saved home |

### **Status Messages:**
| Message | Meaning |
|---------|---------|
| `✓ Loaded home: X,Y,Z` | Using saved location |
| `FIRST TIME SETUP` | No saved home, need setup |
| `✓ Home saved: X,Y,Z` | Location saved successfully |
| `✓ Ready to mine!` | Starting operations |

---

## 🎉 Benefits

✅ **Zero manual input** - No Y/n prompts  
✅ **Instant startup** - Loads and starts immediately  
✅ **Crash recovery** - Auto-recovers after any restart  
✅ **Server friendly** - Survives server restarts  
✅ **Multi-turtle** - Easy to deploy multiple turtles  
✅ **Simple reset** - Delete file to reconfigure  

---

## 🔍 Troubleshooting

**Q: Turtle keeps asking for chest setup?**
- A: No `home_location.txt` found. Check file exists on turtle.

**Q: Home location wrong after restart?**
- A: Delete `home_location.txt` and re-run setup.

**Q: Turtle doesn't auto-start on reboot?**
- A: Check `startup.lua` exists on turtle root directory.

**Q: Want to move to new base location?**
- A: `delete home_location.txt` then run `miner_v2`

**Q: Multiple turtles, same base?**
- A: Set up one turtle, copy `home_location.txt` to others.

---

## 🚀 Complete Workflow

```
┌─────────────────────────────────┐
│     FIRST TIME SETUP            │
├─────────────────────────────────┤
│ 1. Place chest                  │
│ 2. Run: miner_v2               │
│ 3. Press Enter                  │
│ 4. home_location.txt created!  │
└─────────────────────────────────┘
              ↓
┌─────────────────────────────────┐
│     EVERY RESTART AFTER         │
├─────────────────────────────────┤
│ 1. Reboot (or crash)           │
│ 2. startup.lua auto-runs       │
│ 3. Loads saved home            │
│ 4. Starts mining!              │
└─────────────────────────────────┘
```

---

## 💡 Pro Tips

1. **Backup home_location.txt** - Copy to computer for safekeeping
2. **Use startup.lua** - Install on all mining turtles
3. **Name your turtles** - Use `label set Miner1` for easy tracking
4. **Test first** - Verify home location before deploying multiple turtles
5. **Monitor with scanner** - Watch all turtles from computer GUI

---

Enjoy your fully automated mining operation! 🎮⛏️🤖
