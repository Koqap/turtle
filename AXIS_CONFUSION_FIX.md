# Axis Confusion Detection & Debugging

## 🎯 Problem Fixed

**Issue:** Turtle moving on wrong axis
- Needs to move Z (from 90 to 98)
- Instead moves X (from -263 to -290)
- **Moving on completely wrong axis!**

**Root Cause:** Direction mapping error
- `facing` variable may be wrong
- Direction constants (0,1,2,3) may be mapped incorrectly
- No detection of axis confusion

---

## ✅ Solution: Triple Axis Verification

### **1. Movement Plan Display**

**New startup output:**
```
→ Moving to: -259, 46, 98
  Starting from: -263, 45, 90
  Movement needed: X+4, Y+1, Z+8
    → Will move East 4 blocks (X: -263 to -259)
    → Will move Up 1 blocks (Y: 45 to 46)
    → Will move South 8 blocks (Z: 90 to 98)
```

**Shows:**
- Current position
- Target position
- Exact movement needed on each axis
- Which direction each axis requires
- **Verifies plan before moving**

---

### **2. Axis Start Verification**

**Before moving on each axis:**
```
X-axis start: Current=-263, Target=-259, Diff=4
  Moving East 4 blocks... (facing=1, expecting X to INCREASE)

Z-axis start: Current=90, Target=98, Diff=8
  Moving South 8 blocks... (facing=2, expecting Z to INCREASE)
```

**Features:**
- GPS check before each axis
- Shows current, target, and difference
- States expected behavior
- **Catches stale position data**

---

### **3. Axis Confusion Detection**

**After first move on each axis:**
```
Direction check: X -263→-262, Z 90→90
✓ Correct! Moving on X axis

OR

Direction check: X -263→-263, Z 90→91
✗✗ CRITICAL ERROR: Moving on Z axis instead of X!
✗✗ Direction mapping is WRONG!
Stopping X movement...
```

**Detects:**
- Moving on wrong axis entirely
- X movement changing Z instead
- Z movement changing X instead
- **Stops immediately if wrong axis**

---

## 📺 What You'll See

### **Scenario A: Correct Movement**

```
→ Moving to: -259, 46, 98
  Starting from: -263, 45, 90
  Movement needed: X+4, Y+1, Z+8
    → Will move East 4 blocks (X: -263 to -259)
    → Will move Up 1 blocks (Y: 45 to 46)
    → Will move South 8 blocks (Z: 90 to 98)

Y progress: Up 1 (GPS: -263, 46, 90)

X-axis start: Current=-263, Target=-259, Diff=4
  Moving East 4 blocks... (facing=1, expecting X to INCREASE)
    Direction check: X -263→-262, Z 90→90
    ✓ Correct! Moving on X axis
  X progress: 4 (GPS: -259, 46, 90) - 0 blocks to go

Z-axis start: Current=90, Target=98, Diff=8
  Moving South 8 blocks... (facing=2, expecting Z to INCREASE)
    Direction check: X -259→-259, Z 90→91
    ✓ Correct! Moving on Z axis
  Z progress: 5 (GPS: -259, 46, 95) - 3 blocks to go
✓ Arrived at: -259, 46, 98
```

---

### **Scenario B: Axis Confusion (Detected)**

```
→ Moving to: -259, 46, 98
  Starting from: -263, 45, 90
  Movement needed: X+4, Y+1, Z+8
    → Will move East 4 blocks (X: -263 to -259)
    → Will move Up 1 blocks (Y: 45 to 46)
    → Will move South 8 blocks (Z: 90 to 98)

X-axis start: Current=-263, Target=-259, Diff=4
  Moving East 4 blocks... (facing=1, expecting X to INCREASE)
    Direction check: X -263→-263, Z 90→91
    ✗✗ CRITICAL ERROR: Moving on Z axis instead of X!
    ✗✗ Direction mapping is WRONG!
    Stopping X movement...

(Exits X movement loop, tries Z axis)

Z-axis start: Current=-263, Target=98, Diff=8
  Moving South 8 blocks... (facing=2, expecting Z to INCREASE)
    Direction check: X -263→-262, Z 90→90
    ✗✗ CRITICAL ERROR: Moving on X axis instead of Z!
    ✗✗ Direction mapping is WRONG!
    Stopping Z movement...

ERROR: Cannot navigate - direction mapping broken!
```

---

## 🔧 Technical Details

### **Movement Plan Calculation:**

```lua
local xMove = targetX - lastKnown.x
local yMove = targetY - lastKnown.y
local zMove = targetZ - lastKnown.z

print("Movement needed: X%+d, Y%+d, Z%+d", xMove, yMove, zMove)

-- Show detailed plan for each axis
if math.abs(xMove) > 0 then
    if xMove > 0 then
        print("Will move East %d blocks (X: %d to %d)", xMove, lastKnown.x, targetX)
    else
        print("Will move West %d blocks (X: %d to %d)", abs(xMove), lastKnown.x, targetX)
    end
end
```

**Benefits:**
- User sees plan before turtle moves
- Easy to verify if plan is correct
- Can spot issues before movement starts

---

### **Axis Start GPS Check:**

```lua
-- Before X axis movement:
local gx, gy, gz = gps.locate(5)
if gx then
    lastKnown = {x=gx, y=gy, z=gz}
    print("X-axis start: Current=%d, Target=%d, Diff=%d", 
          lastKnown.x, targetX, targetX - lastKnown.x)
end
```

**Catches:**
- Stale position data from previous axis
- GPS errors during Y movement
- Position drift
- **Fresh GPS data for each axis**

---

### **Axis Confusion Detection:**

```lua
-- After first move on X axis:
local actualX = floor(gps_x)
local actualZ = floor(gps_z)
local oldX = lastKnown.x
local oldZ = lastKnown.z

local xChanged = (actualX != oldX)
local zChanged = (actualZ != oldZ)

-- X axis should change, Z should NOT
if not xChanged and zChanged then
    print("✗✗ CRITICAL ERROR: Moving on Z axis instead of X!")
    print("✗✗ Direction mapping is WRONG!")
    break  -- Stop X movement
end
```

**Detection logic:**

| Axis Moving | Expected | Actual | Result |
|-------------|----------|--------|--------|
| **X** | X changes | X changes | ✓ Correct |
| **X** | X changes | Z changes | ✗ WRONG AXIS! |
| **Z** | Z changes | Z changes | ✓ Correct |
| **Z** | Z changes | X changes | ✗ WRONG AXIS! |

---

## 🐛 Diagnostics

### **If you see "CRITICAL ERROR: Moving on Z axis instead of X":**

**This means:**
- Turtle is moving on Z when it should move on X
- Direction constants are swapped
- `facing` variable is off by 90° or 270°

**Common causes:**
1. **North/East swapped:**
   ```
   Should be: 0=North, 1=East
   Actually:  0=East, 1=North
   ```

2. **Facing initialized wrong:**
   ```
   Turtle facing East
   Code thinks: facing=0 (North)
   Should be:   facing=1 (East)
   ```

3. **Coordinate system rotated:**
   ```
   Expected: X=East/West, Z=North/South
   Actual:   X=North/South, Z=East/West
   ```

---

### **Direction Constant Mapping:**

**Current mapping:**
```
facing = 0 → North  → Z decreases (z-1)
facing = 1 → East   → X increases (x+1)
facing = 2 → South  → Z increases (z+1)
facing = 3 → West   → X decreases (x-1)
```

**If axis confusion detected, mapping might actually be:**
```
facing = 0 → East   → X increases (WRONG!)
facing = 1 → South  → Z increases (WRONG!)
facing = 2 → West   → X decreases (WRONG!)
facing = 3 → North  → Z decreases (WRONG!)
```

---

## 📊 Debug Output Analysis

### **Example 1: Correct Mapping**

```
Movement needed: X+4, Y+1, Z+8
X-axis start: Current=-263, Target=-259, Diff=4
  Moving East 4 blocks... (facing=1, expecting X to INCREASE)
    Direction check: X -263→-262, Z 90→90
    ✓ X changed, Z didn't change → Correct!
```

**Analysis:**
- Needs to move X from -263 to -259 (4 blocks east)
- Turned to facing=1 (East)
- Moved forward
- GPS shows X increased (-263 → -262)
- GPS shows Z unchanged (90 → 90)
- **✓ Correct axis!**

---

### **Example 2: Wrong Mapping**

```
Movement needed: X+4, Y+1, Z+8
X-axis start: Current=-263, Target=-259, Diff=4
  Moving East 4 blocks... (facing=1, expecting X to INCREASE)
    Direction check: X -263→-263, Z 90→91
    ✗ X didn't change, Z changed → WRONG!
```

**Analysis:**
- Needs to move X from -263 to -259
- Turned to facing=1 (thinks it's East)
- Moved forward
- GPS shows X unchanged (-263 → -263)
- GPS shows Z increased (90 → 91)
- **✗ Moving on Z axis when should move X!**
- **facing=1 is NOT East, it's actually South!**

---

## 🎯 Expected Behavior

### **With Correct Mapping:**

```
→ Moving to: -259, 46, 98
  Movement needed: X+4, Y+1, Z+8

Y: 45 → 46 (1 block)
X: -263 → -259 (4 blocks)
Z: 90 → 98 (8 blocks)

✓ Each axis moves independently
✓ No axis confusion
✓ Arrives at exact target
```

---

### **With Wrong Mapping:**

```
→ Moving to: -259, 46, 98
  Movement needed: X+4, Y+1, Z+8

X movement tries to run:
  ✗ Z changes instead of X
  ✗ Detected and stopped

Z movement tries to run:
  ✗ X changes instead of Z
  ✗ Detected and stopped

ERROR: Cannot navigate!
```

---

## 🚀 How to Use Debug Output

### **Step 1: Check Movement Plan**

```
Movement needed: X+4, Y+1, Z+8
  → Will move East 4 blocks (X: -263 to -259)
  → Will move South 8 blocks (Z: 90 to 98)
```

**Verify:**
- Is the plan correct?
- Are the directions right (East for X+, South for Z+)?

---

### **Step 2: Check Axis Start**

```
X-axis start: Current=-263, Target=-259, Diff=4
Z-axis start: Current=90, Target=98, Diff=8
```

**Verify:**
- Does current match expected?
- Is diff calculation correct?

---

### **Step 3: Check Direction Verification**

```
Moving East 4 blocks... (facing=1, expecting X to INCREASE)
  Direction check: X -263→-262, Z 90→90
```

**Verify:**
- Did correct axis change? (X should change, Z shouldn't)
- Did it change in correct direction? (X should increase)
- If wrong axis changed: **Direction mapping broken!**

---

## 📝 Summary

### **Three Detection Layers:**

✅ **Layer 1: Movement Plan**
- Shows intended movement before starting
- Verify plan is correct
- Catch logical errors early

✅ **Layer 2: Axis Start Verification**
- GPS check before each axis
- Fresh position data
- Catch position drift

✅ **Layer 3: Axis Confusion Detection**
- Check which axis actually changed
- Detect wrong axis movement
- Stop immediately if wrong

---

### **Debug Output:**

| Stage | What It Shows | What to Check |
|-------|---------------|---------------|
| **Plan** | Movement needed on each axis | Is plan correct? |
| **Start** | Current/target for this axis | Is position fresh? |
| **Check** | Which axis actually changed | Did right axis move? |

---

## 🔧 Try It Now

```bash
# On turtle:
reboot

# Watch for:
# "Movement needed: X+4, Y+1, Z+8"
# "X-axis start: Current=-263, Target=-259"
# "Direction check: X -263→-262, Z 90→90"
# 
# If you see "CRITICAL ERROR: Moving on Z axis instead of X!"
# → Direction mapping is broken!
# → Report the error output for diagnosis
```

---

**Axis confusion detection active! Will detect and report wrong axis movement immediately!** 🎯✅
