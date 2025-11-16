# GPS Troubleshooting Guide

## 🚨 Problem: Turtle Navigates to Wrong Location

**Symptoms:**
- Turtle goes to wrong coordinates (e.g., -279, 45, -87 instead of -259, 46, -88)
- Turtle moves infinitely without reaching home
- Position seems off by ~20 blocks

**Root Cause:** GPS not working correctly or turtle using wrong position data

---

## ✅ What Was Fixed

### **1. Better GPS Validation**
```lua
-- Old: Try GPS once, fallback to lastKnown (0,0,0)
local x, y, z = gps.locate(2)

-- New: Try GPS 3 times with 5-second timeout
for attempt = 1, 3 do
    local x, y, z = gps.locate(5)
    if x then return position end
    sleep(1)  -- Wait between attempts
end
```

### **2. Position Debug Output**
Now shows:
```
Getting GPS coordinates...
✓ GPS Position: -259, 46, -88

⚠ Not at home! Distance: 63 blocks
  Current: -322, 49, -85
  Home: -259, 46, -88

→ Moving to: -259, 46, -88
  Starting from: -322, 49, -85
  X: -312/-259
  X: -302/-259
  ...
✓ Arrived at: -259, 46, -88
```

### **3. Stuck Detection**
Detects if turtle stops making progress:
```
⚠ WARNING: Stuck at X=-279
```

---

## 🔍 Diagnosing GPS Issues

### **Test 1: Check GPS Works**
```lua
-- On turtle, run:
lua
x, y, z = gps.locate(5)
print(x, y, z)
```

**Expected:** Shows your coordinates  
**If nil:** GPS not working!

---

### **Test 2: Check GPS Consistency**
```lua
-- Run multiple times:
for i=1,5 do
    x,y,z = gps.locate(5)
    print(i, x, y, z)
    sleep(1)
end
```

**Expected:** Same coordinates every time  
**If different:** GPS satellites misconfigured!

---

### **Test 3: Verify Home Coordinates**
```lua
-- On turtle:
edit home_location.txt
```

**Check:**
- Are coordinates correct?
- Do they match your actual home location?

---

## 🛠️ Common Issues & Fixes

### **Issue 1: No GPS Signal**

**Symptoms:**
```
ERROR: GPS signal not available!
Cannot determine current position
```

**Solution:**
1. Set up GPS satellites (need 4 computers in sky)
2. Position them in a square formation
3. Run GPS host program on each
4. Test with `gps.locate(5)` on turtle

---

### **Issue 2: GPS Coordinates Wrong**

**Symptoms:**
- Turtle thinks it's at 0, 0, 0
- Turtle navigates to random location
- Says "Distance: 259 blocks" when at home

**Solution:**
1. Check GPS satellite positions:
   ```
   Satellite 1: X+, Z+ (e.g., 100, 80, 100)
   Satellite 2: X+, Z- (e.g., 100, 80, -100)
   Satellite 3: X-, Z+ (e.g., -100, 80, 100)
   Satellite 4: X-, Z- (e.g., -100, 80, -100)
   ```

2. Make sure satellites are above Y=80
3. Verify satellites are far apart (200+ blocks)
4. Restart GPS host programs

---

### **Issue 3: Turtle Goes to Wrong Coordinates**

**Example:** Home is -259, 46, -88 but turtle goes to -279, 45, -87

**Diagnosis Steps:**

**Step 1:** Check what GPS returns
```bash
# On turtle:
lua
print(gps.locate(5))
```

**Step 2:** Compare to saved home
```bash
edit home_location.txt
# Check x, y, z values
```

**Step 3:** Watch debug output
```bash
miner_v2
# Look for:
# "✓ GPS Position: ..."
# "→ Moving to: ..."
# "Starting from: ..."
```

**If GPS shows wrong position:**
- GPS satellites misconfigured
- Fix satellite positions

**If home_location.txt is wrong:**
```bash
delete home_location.txt
miner_v2
# Re-setup home
```

---

### **Issue 4: Turtle Stuck in Loop**

**Symptoms:**
- Moves back and forth
- Never reaches target
- "Stuck at X=..." warnings

**Solutions:**

**A) GPS not updating:**
- Turtle using old cached position
- GPS timeout too short
- **Fix:** Increased timeout to 5 seconds

**B) Obstacle blocking:**
- Turtle can't dig through
- Protected area
- Bedrock/unbreakable block

**C) Fuel ran out:**
```bash
# Check fuel:
lua
print(turtle.getFuelLevel())
```

---

## 📋 Setup Checklist

### **GPS Satellites Setup:**
- [ ] 4 computers placed in sky (Y > 80)
- [ ] Positioned in square (200+ blocks apart)
- [ ] Running GPS host program
- [ ] Test with `gps.locate()` works

### **Turtle Setup:**
- [ ] Has wireless modem
- [ ] Modem is on (rednet.open)
- [ ] Can reach GPS satellites
- [ ] `home_location.txt` has correct coordinates

### **Home Location:**
- [ ] Chest placed behind turtle
- [ ] Turtle facing away from chest
- [ ] GPS works at home location
- [ ] Coordinates in home_location.txt match actual location

---

## 🔧 Manual Fixes

### **Fix 1: Reset Home Location**
```bash
# On turtle:
delete home_location.txt
miner_v2
# Follow setup prompts
```

### **Fix 2: Manually Set Home**
```bash
# Edit home file:
edit home_location.txt

# Set to:
{
  x = -259,   -- Your actual home X
  y = 46,     -- Your actual home Y
  z = -88,    -- Your actual home Z
  facing = 1  -- 0=N, 1=E, 2=S, 3=W
}

# Save and exit
```

### **Fix 3: Test Navigation Manually**
```bash
# On turtle:
lua
-- Test GPS:
x,y,z = gps.locate(5)
print("GPS:", x, y, z)

-- Test moveAbs:
-- (function must be loaded first)
```

---

## 📊 Debug Output Reference

### **Normal Output:**
```
Checking position...
Getting GPS coordinates...
✓ GPS Position: -322, 49, -85
⚠ Not at home! Distance: 63 blocks
  Current: -322, 49, -85
  Home: -259, 46, -88

AUTO-NAVIGATING back to home base...

→ Moving to: -259, 46, -88
  Starting from: -322, 49, -85
  X: -312/-259
  X: -302/-259
  X: -292/-259
  X: -282/-259
  X: -272/-259
  X: -262/-259
  Z: -87/-88
✓ Arrived at: -259, 46, -88
```

### **GPS Problem:**
```
Getting GPS coordinates...
═══════════════════════════════════
ERROR: GPS signal not available!
═══════════════════════════════════
Cannot determine current position
```

### **Wrong Position:**
```
✓ GPS Position: 0, 0, 0  ← WRONG!
⚠ Not at home! Distance: 393 blocks  ← TOO FAR!
```

### **Stuck:**
```
→ Moving to: -259, 46, -88
  Starting from: -322, 49, -85
  X: -322/-259
  X: -322/-259  ← Not moving!
  WARNING: Stuck at X=-322
```

---

## ✅ Quick Fixes Summary

| Problem | Quick Fix |
|---------|-----------|
| No GPS signal | Set up GPS satellites |
| Wrong coordinates | Check GPS satellite positions |
| Goes to wrong place | Delete home_location.txt and re-setup |
| Stuck in loop | Check for obstacles/protected areas |
| Coordinates off by ~20 | GPS satellites too close together |
| Says at 0,0,0 | GPS not working, fix satellites |

---

## 🎯 What to Check Now

**After restarting turtle, watch for:**

1. **"Getting GPS coordinates..."**
   - Should show your actual coordinates
   - NOT 0, 0, 0

2. **"✓ GPS Position: X, Y, Z"**
   - Should be correct
   - Should match `gps.locate()` output

3. **"Distance: X blocks"**
   - Should be reasonable (<100 blocks)
   - If >200, something is wrong

4. **"→ Moving to: ..."** and **"Starting from: ..."**
   - Both should show correct coordinates
   - Should match GPS output

5. **Progress updates**
   - "X: -312/-259" shows movement
   - Should progress toward target
   - If stuck at same number, there's a problem

---

**Use this output to identify exactly where the problem is!** 🔍
