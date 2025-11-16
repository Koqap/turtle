# "No Ore" Debugging Guide

## 🐛 Problem

**Scanner detects ores but turtle says "No ores available"**

This happens when:
- Scanner successfully scans and finds ores
- Ores are stored in scanner's memory
- But when turtle requests a path, scanner reports no available ores

---

## 🔍 Debug Output Added

I've added comprehensive debug logging to help diagnose this issue. When the turtle requests a path, the scanner will now print:

### **1. Basic Info**
```
[12:34] Path request from turtle 5
  Turtle at: -259,46,-88
  Total ores in system: 24        ← How many ores scanner has stored
```

### **2. Filter Status**
```
  Filter Debug:
    Using GUI filter:              ← Which filter is active
      iron: ON
      coal: ON
      gold: ON
      diamond: ON
      copper: OFF
      redstone: OFF
      lapis: OFF
      emerald: OFF
```

**OR**
```
  Filter Debug:
    Using turtle filter:           ← Using turtle's ORE_FILTER
      iron
      coal
      gold
      diamond
```

### **3. Sample Ores**
```
  First 3 ores in system:
    1: minecraft:iron_ore at -245,46,-92 [not-claimed, not-visited]
    2: minecraft:coal_ore at -250,48,-85 [not-claimed, not-visited]
    3: minecraft:gold_ore at -255,45,-100 [claimed, not-visited]
```

### **4. Ore Statistics**
```
  Ore states: 2 claimed, 5 visited, 17 available
  Ore stats: 17 total, 15 filtered, 8 in range, 7 too far
  Target: minecraft:iron_ore at -245,46,-92 (distance: 15 blocks)
```

---

## 📋 Common Issues & Solutions

### **Issue 1: "Total ores in system: 0"**

**Problem:** Scanner has no ores stored at all

**Causes:**
1. Initial scan never completed
2. Scan failed silently
3. Scanner restarted and lost data

**Solutions:**
```bash
# On scanner:
1. Click "SCAN" button manually
2. Check console for scan results
3. Should see: "Scanned X blocks, total ores: Y"

# If scan shows 0 blocks:
- Check geo_scanner_2 is connected
- Run: peripherals
- Should show "geo_scanner_2" in list
- Check scanner is powered and loaded chunk

# If geo_scanner not found:
- Verify peripheral name matches "geo_scanner_2"
- Or update scanner script with correct name
```

---

### **Issue 2: "Ore states: 0 claimed, 0 visited, 0 available"**

**But "Total ores in system" > 0**

**Problem:** All ores are already marked as claimed or visited

**Causes:**
1. Scanner restarted but kept old mapData
2. All ores were already mined
3. Ores marked as failed

**Solutions:**
```bash
# On scanner:
1. Click "SCAN" button to find new ores
2. Or restart scanner to clear old data
3. Check "Ores Tracked: X" in status bar

# If number keeps decreasing:
- Turtle is mining ores (good!)
- Scanner needs to scan new areas
- Move scanner or turtle to new location
```

---

### **Issue 3: "Using GUI filter: all OFF"**

**Problem:** GUI filter has all ore types disabled

**Example:**
```
Filter Debug:
  Using GUI filter:
    iron: OFF         ← All disabled!
    coal: OFF
    gold: OFF
    diamond: OFF
```

**Solution:**
```bash
# On scanner GUI:
1. Find "ORE FILTERS:" section
2. Click ore type buttons to enable
3. Button colors:
   - GREEN = Enabled (will mine)
   - RED = Disabled (will skip)
4. Enable at least: iron, coal, gold, diamond
```

---

### **Issue 4: "Ore stats: X total, 0 filtered"**

**Problem:** Filter is rejecting all ores

**Causes:**
1. Ore names don't match filter
2. Filter looking for wrong names
3. Deepslate vs normal ore mismatch

**Example Issue:**
```
First 3 ores in system:
  1: minecraft:deepslate_iron_ore at -245,46,-92
  2: minecraft:deepslate_coal_ore at -250,48,-85

Filter Debug:
  Using GUI filter:
    iron: ON
    coal: ON

Ore stats: 15 total, 0 filtered  ← Nothing matches!
```

**Why:** Filter checks if `oreName:find("iron")` matches
- `"minecraft:deepslate_iron_ore":find("iron")` → **FOUND at position 23** ✓
- Should work!

**If this happens:**
```lua
-- Check scanner code, the filter should work for both:
-- "minecraft:iron_ore" ✓
-- "minecraft:deepslate_iron_ore" ✓
```

---

### **Issue 5: "Ore stats: X filtered, 0 in range, X too far"**

**Problem:** All ores are beyond MAX_MINING_RANGE (60 blocks)

**Example:**
```
Turtle at: -259,46,-88
Ore stats: 15 total, 15 filtered, 0 in range, 15 too far
No ores within 60 blocks (all ores too far)
```

**Solutions:**

**Option A: Move turtle closer to ores**
```bash
# On scanner:
- Look at GUI "SMARTMINER - ORES DETECTED:"
- Note ore locations
- Move turtle to within 60 blocks

# Example:
Ores at: -200,46,-50
Turtle at: -259,46,-88
Distance: |-200-(-259)| + |46-46| + |-50-(-88)| 
        = 59 + 0 + 38 = 97 blocks (too far!)

Move turtle to: -210,46,-60
Distance: 10 + 0 + 10 = 20 blocks (good!)
```

**Option B: Increase mining range**
```lua
-- In scanner script (line 14):
local MAX_MINING_RANGE = 60  -- Change to 100 or more

-- Trade-offs:
- Larger range = More ores available
- Larger range = Longer travel time
- Larger range = More fuel needed
```

**Option C: Scan new area**
```bash
# Move scanner computer closer to turtle
# Then click "SCAN" button
# This will find ores near turtle's location
```

---

### **Issue 6: Filter not matching ore names**

**Symptom:**
```
First 3 ores in system:
  1: minecraft:iron_ore at -245,46,-92
  
Filter Debug:
  Using GUI filter:
    iron: ON

Ore stats: 10 total, 0 filtered    ← Should be filtering!
```

**Debug the filter manually:**
```lua
-- Test in Lua console:
> oreName = "minecraft:iron_ore"
> oreType = "iron"
> enabled = true
> print(oreName:find(oreType))      -- Should print position number
23

> print(oreName:find(oreType) and enabled)
true

> -- If both true, filter should pass!
```

**If filter still not working:**
- Check for typos in ore type names
- Check Lua syntax in matchesFilter function
- Verify BASALT and oreFilterEnabled are defined

---

## 🧪 Testing Procedure

### **1. Verify Scanner Has Ores**

```bash
# On scanner:
> scanner

# After startup:
Check status bar: "Ores:X" should be > 0

# If 0:
Click "SCAN" button
Wait 2-3 seconds
Check "Ores:X" updated
```

---

### **2. Check Filter Configuration**

```bash
# On scanner GUI:
Look at "ORE FILTERS:" section
Verify ore buttons:
  [IRON] = GREEN
  [COAL] = GREEN
  [GOLD] = GREEN
  [DIAM] = GREEN
  
If RED, click to toggle to GREEN
```

---

### **3. Start Turtle and Watch Debug Output**

```bash
# On turtle:
> miner_v2

# When turtle requests path, scanner console shows:
[12:34] Path request from turtle 5
  Turtle at: -259,46,-88
  Total ores in system: 24         ← Should be > 0
  
  Filter Debug:
    Using GUI filter:
      iron: ON                      ← Should be ON
      coal: ON
      gold: ON
      diamond: ON
      
  First 3 ores in system:
    1: minecraft:iron_ore ...       ← Should show ores
    2: minecraft:coal_ore ...
    3: minecraft:gold_ore ...
    
  Ore states: 0 claimed, 0 visited, 24 available  ← available > 0
  Ore stats: 24 total, 20 filtered, 15 in range, 5 too far
  Target: minecraft:iron_ore ...   ← Should select target
```

---

### **4. Interpret Results**

| Debug Output | Meaning | Action |
|--------------|---------|--------|
| `Total ores: 0` | No scan data | Click SCAN |
| `0 available` | All claimed/visited | Click SCAN for new area |
| `0 filtered` | Filter rejecting all | Check filter buttons |
| `0 in range` | All ores too far | Move turtle or increase range |
| `Target: ...` | Success! | Turtle should start mining |

---

## 🔧 Quick Fixes

### **Fix 1: Reset Scanner**

```bash
# Restart scanner:
1. Press Ctrl+T on scanner
2. Run: scanner
3. Click START
4. Click SCAN
5. Verify "Ores:X" shows count
```

---

### **Fix 2: Enable All Filters**

```bash
# On scanner GUI:
Click all ore filter buttons until GREEN:
- IRON → GREEN
- COAL → GREEN  
- GOLD → GREEN
- DIAM → GREEN
```

---

### **Fix 3: Force New Scan**

```bash
# On scanner:
1. Click SCAN button
2. Wait for scan complete
3. Check console: "Scanned X blocks, total ores: Y"
4. Check status bar: "Ores:Y" updated
```

---

### **Fix 4: Move Turtle Closer**

```bash
# If ores too far:
1. Check ore locations in scanner GUI
2. Manually move turtle closer (within 60 blocks)
3. Or use teleport if testing:
   /tp @e[type=turtle] -200 46 -50
```

---

## 📊 Debug Output Example (Working)

```
[12:34:56] Path request from turtle 5
  Turtle at: -259,46,-88
  Total ores in system: 24

  Filter Debug:
    Using GUI filter:
      iron: ON
      coal: ON
      gold: ON
      diamond: ON
      copper: OFF
      redstone: OFF
      lapis: OFF
      emerald: OFF

  First 3 ores in system:
    1: minecraft:iron_ore at -245,46,-92 [not-claimed, not-visited]
    2: minecraft:coal_ore at -250,48,-85 [not-claimed, not-visited]
    3: minecraft:gold_ore at -255,45,-88 [not-claimed, not-visited]

  Ore states: 0 claimed, 0 visited, 24 available
  Ore stats: 24 total, 20 filtered, 15 in range, 5 too far
  
  Target: minecraft:iron_ore at -245,46,-92 (distance: 15 blocks)
  Next: minecraft:coal_ore at distance 20
  Next: minecraft:gold_ore at distance 25
```

**Turtle output:**
```
=== Cycle 1 ===
Requesting path from -259,46,-88
✓ Path received: 1 steps
Target: minecraft:iron_ore at -245,46,-92
```

**✓ Success!**

---

## 📝 Summary Checklist

Before reporting issue, verify:

- [ ] Scanner has ores: `Total ores in system: > 0`
- [ ] Ores available: `X available > 0` (not all claimed/visited)
- [ ] Filter enabled: At least one ore type shows `ON`
- [ ] Ores match filter: `X filtered > 0`
- [ ] Ores in range: `X in range > 0`
- [ ] Distance reasonable: Turtle within 60 blocks of ores

**If all checks pass but still "no ore":**
- Share the full debug output from scanner console
- Include turtle's output
- Include screenshot of scanner GUI

---

**Debug output will help identify the exact cause of "no ore" issue!** 🔍🐛✅
