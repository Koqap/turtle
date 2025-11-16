# Return Home Button - Feature Guide

## 🆕 What's New

Added **RETURN** button to scanner GUI to remotely command all turtles to return to base!

## 📍 Location

```
Scanner GUI Layout:
Row 3: [SCAN NOW] [RETURN] [IRON] [COAL] [GOLD]...
```

## 🎮 How to Use

### Send Return Command:
1. Click **RETURN** button on scanner GUI
2. All connected turtles receive command
3. Turtles return home, deposit items, and wait

### What Happens:

**On Scanner:**
```
Activity Log:
[14:32:15] Sent RETURN command to Turtle #3
[14:32:15] >>> 1 turtle(s) returning home <<<
[14:32:16] Turtle 3: returning home
[14:32:25] Turtle 3: at home
```

**On Turtle:**
```
*** RETURN HOME command received! ***
Returning to base...
[Moving home...]
Depositing items...
At home. Press Ctrl+T to stop or waiting for next command...
```

## 🔄 What Turtle Does:

1. ✅ Receives `return_home` command
2. ✅ Sends "returning home" status to scanner
3. ✅ Navigates back to home position
4. ✅ Deposits all items to chest
5. ✅ Sends "at home" status to scanner
6. ✅ Waits 5 seconds, then resumes mining

## 📊 Status Updates

Turtle status in GUI shows:
- **"returning home"** - Turtle traveling back
- **"at home"** - Turtle at base, items deposited
- **"idle"** - Ready to resume mining

## 💡 Use Cases

### Emergency Stop:
- Storm coming? Click RETURN!
- Server restart? Click RETURN!
- Need items? Click RETURN!

### Maintenance:
- Refuel turtles at base
- Clear inventory manually
- Upgrade turtle equipment

### Multi-Turtle Coordination:
- Return all turtles at once
- Synchronize mining operations
- Collect all gathered resources

## 🎯 Features

✅ **Remote control** - Command from scanner GUI
✅ **Multi-turtle** - Affects all connected turtles
✅ **Status feedback** - See when turtles arrive home
✅ **Auto-resume** - Turtles continue mining after 5 seconds
✅ **Safe deposit** - Items automatically stored in chest
✅ **Non-blocking** - Scanner continues operating

## 🔧 Technical Details

### Message Protocol:
```lua
-- Scanner sends:
{
  type = "return_home"
}

-- Turtle responds:
{
  type = "status_update",
  status = "returning home" | "at home",
  position = {x, y, z}
}
```

### Button Position:
- X: 13, Y: 3
- Width: 8 characters
- Color: Orange background
- Text: "RETURN"

## ⚠️ Important Notes

1. **Turtle auto-resumes** - After 5 seconds at home, turtle will request new ores
2. **Press Ctrl+T** - If you want turtle to stay home, press Ctrl+T to stop it
3. **Multiple turtles** - Button sends command to ALL connected turtles
4. **No confirmation** - Button acts immediately (no "are you sure?")

## 🚀 Quick Commands

### Stop turtle at home:
1. Click RETURN
2. Wait for "at home" status
3. Press Ctrl+T on turtle to stop

### Quick item collection:
1. Click RETURN
2. Wait 30 seconds
3. Remove items from chest
4. Turtle auto-resumes mining

### Emergency shutdown:
1. Click RETURN
2. Wait for all turtles to reach home
3. Stop scanner (press Q)
4. Press Ctrl+T on each turtle

## 📝 Examples

### Single Turtle:
```
[14:30:00] Sent RETURN command to Turtle #3
[14:30:00] >>> 1 turtle(s) returning home <<<
[14:30:01] Turtle 3: returning home
[14:30:15] Turtle 3: at home
```

### Multiple Turtles:
```
[14:30:00] Sent RETURN command to Turtle #3
[14:30:00] Sent RETURN command to Turtle #5
[14:30:00] Sent RETURN command to Turtle #7
[14:30:00] >>> 3 turtle(s) returning home <<<
[14:30:01] Turtle 3: returning home
[14:30:02] Turtle 5: returning home
[14:30:02] Turtle 7: returning home
[14:30:15] Turtle 3: at home
[14:30:18] Turtle 5: at home
[14:30:20] Turtle 7: at home
```

### No Turtles Connected:
```
[14:30:00] No turtles connected!
```

---

## 🎉 Enjoy Your Remote Control!

Now you can safely recall all your mining turtles with a single click! 🎮⛏️🏠
