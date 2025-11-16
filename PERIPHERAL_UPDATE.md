# Peripheral Configuration Update

## 🔧 Changes Made

Updated peripheral names to match your hardware configuration:

---

## 📡 Geo Scanner

### **Old Configuration:**
```lua
local scanner = peripheral.wrap("geo_scanner_1")
```

### **New Configuration:**
```lua
local scanner = peripheral.wrap("geo_scanner_2")
```

**Files Updated:**
- `/workspace/scanner`

**Messages Updated:**
- Startup: `✓ Geo Scanner: Found (geo_scanner_2)`
- Error: `⚠ Geo Scanner: Not found (geo_scanner_2)`
- GUI Log: `Check geo_scanner_2 connection`

---

## 🌍 Environment Detector

### **Old Configuration:**
```lua
-- Used peripheral.find() which searches for any environmentDetector
local envDetector = peripheral.find("environmentDetector")
```

### **New Configuration:**
```lua
-- Now uses peripheral.wrap() for specific named peripheral
local envDetector = peripheral.wrap("environment_detector_1")
```

**Why the Change?**
- `peripheral.find()` searches for any peripheral of that type
- `peripheral.wrap()` connects to a specific named peripheral
- More reliable and explicit configuration
- Matches your hardware naming convention

**Files Updated:**
- `/workspace/scanner`
- `/workspace/miner_v2`

---

## 📋 Setup Checklist

Before running the updated scripts, ensure your peripherals are named correctly:

### **On Scanner Computer:**

```bash
# Check peripheral names
> peripherals

# Should show:
geo_scanner_2
environment_detector_1
left (wireless modem)
# ... other peripherals
```

### **If Names Don't Match:**

**To rename Geo Scanner:**
```bash
# In CC:Tweaked, right-click the geo scanner block
# Or use the rename command if available
```

**To rename Environment Detector:**
```bash
# Right-click the Environment Detector block
# Use the Advanced Peripherals naming interface
# Set name to: environment_detector_1
```

---

## 🎯 Expected Behavior

### **Scanner Startup:**

```
═══════════════════════════════════════
  SMARTMINER SYSTEM - SCANNER
═══════════════════════════════════════
Computer ID: 3
Protocol: smartminer
✓ Modem: Found on left
✓ Geo Scanner: Found (geo_scanner_2)        ← Updated message
✓ Environment Detector: Found               ← Will show if connected
  Max scan radius: 8 blocks
Disk drive: Disabled (to prevent out of space errors)
```

**If Geo Scanner not found:**
```
⚠ Geo Scanner: Not found (geo_scanner_2)
⚠ Check peripheral connection and name!
```

**If Environment Detector not found:**
```
⚠ Environment Detector: Not found
  (Smart navigation features disabled)
```

---

### **Miner Startup:**

```
════════════════════════════════════
 AUTONOMOUS MINER v2 - Enhanced
════════════════════════════════════
✓ Modem found
Testing connection to computer...
✓ Connected to computer ID: 3

Checking for Environment Detector...
✓ Environment Detector found!              ← Will show if connected
  Using advanced chest detection
```

**If Environment Detector not found:**
```
⚠ Environment Detector: Not found
  (Using standard turtle.inspect() method)
```

---

## 🔍 Troubleshooting

### **"Geo Scanner: Not found"**

**Possible causes:**
1. Peripheral not connected to computer
2. Peripheral named differently
3. Geo scanner not powered/loaded

**Solutions:**
```bash
# Check connected peripherals
> peripherals

# Expected: geo_scanner_2 in the list

# If shows different name:
Option 1: Rename the geo scanner to geo_scanner_2
Option 2: Update scanner script with correct name:
  local scanner = peripheral.wrap("your_actual_name")
```

---

### **"Environment Detector: Not found"**

**Possible causes:**
1. Advanced Peripherals mod not installed
2. Environment Detector not connected
3. Environment Detector named differently
4. Chunk not loaded

**Solutions:**
```bash
# Check connected peripherals
> peripherals

# Expected: environment_detector_1 in the list

# If shows different name (e.g., environmentDetector_0):
Update scripts with correct name:
  local envDetector = peripheral.wrap("environmentDetector_0")

# If not in list:
- Check Environment Detector is connected to computer/network
- Check Advanced Peripherals mod is installed
- Reload chunk or restart game
```

---

### **Using peripheral.find() vs peripheral.wrap()**

**peripheral.find():**
```lua
-- Searches for ANY peripheral of the given type
local envDetector = peripheral.find("environmentDetector")

-- Pros: 
--   - Works with any name
--   - Finds peripheral automatically
-- Cons:
--   - Might find wrong peripheral if multiple exist
--   - Less explicit/predictable
```

**peripheral.wrap():**
```lua
-- Connects to SPECIFIC named peripheral
local envDetector = peripheral.wrap("environment_detector_1")

-- Pros:
--   - Explicit and predictable
--   - Works with specific peripheral
--   - Better for multi-peripheral setups
-- Cons:
--   - Requires exact name match
--   - Returns nil if name wrong (but that's good for debugging!)
```

**We now use `peripheral.wrap()` for:**
✅ More reliable configuration
✅ Better error messages
✅ Explicit peripheral selection
✅ Consistency with geo scanner setup

---

## 🧪 Testing

### **Test Scanner:**

```bash
# On scanner computer:
> scanner

# Check startup messages:
✓ Should show "geo_scanner_2" found
✓ Should show "Environment Detector" status

# In GUI:
✓ Status bar shows "Geo:OK" and "EnvDet:OK/NO"
✓ Click SCAN - should detect ores
✓ Monitor shows system status with EnvDet info
```

---

### **Test Miner:**

```bash
# On turtle:
> miner_v2

# Check startup messages:
✓ Should show Environment Detector status
✓ If found, uses advanced chest detection
✓ If not found, uses standard method

# During operation:
✓ Turtle should detect chest automatically (if envDet present)
✓ Smart navigation should work
✓ Position updates on scanner monitor
```

---

## 📝 Configuration Summary

| Peripheral | Old Method | New Method | Name |
|------------|------------|------------|------|
| **Geo Scanner** | `wrap("geo_scanner_1")` | `wrap("geo_scanner_2")` | `geo_scanner_2` |
| **Environment Detector** | `find("environmentDetector")` | `wrap("environment_detector_1")` | `environment_detector_1` |
| **Wireless Modem** | `wrap(modemSide)` | `wrap(modemSide)` | (unchanged) |

---

## 🚀 Quick Start

### **1. Verify Peripheral Names:**

```bash
> peripherals
```

Should show:
- `geo_scanner_2`
- `environment_detector_1`
- Wireless modem on some side

---

### **2. Rename if Needed:**

If your peripherals have different names, either:
- **Option A:** Rename them to match (recommended)
- **Option B:** Edit the scripts to match your names

---

### **3. Run Scanner:**

```bash
> scanner
```

Check for ✓ marks next to both scanners.

---

### **4. Run Miner:**

```bash
> miner_v2
```

Check for ✓ mark next to Environment Detector (if you have one).

---

## 💡 Tips

**If you don't have geo_scanner_2:**
- You might still have `geo_scanner_1`
- Check with `> peripherals`
- Either rename it or change script back

**If you don't have environment_detector_1:**
- The system will still work!
- Environment Detector is optional
- You'll see "EnvDet:NO" but that's okay
- Smart features will be disabled but basic mining works

**If you have multiple geo scanners:**
- Name them uniquely (geo_scanner_1, geo_scanner_2, etc.)
- Update script to use correct one
- Consider using `peripheral.find()` if you want automatic selection

---

## ✅ Changes Applied

✅ Geo Scanner: `geo_scanner_1` → `geo_scanner_2`
✅ Environment Detector: `peripheral.find()` → `peripheral.wrap()`
✅ All messages updated to reflect new names
✅ Error messages updated
✅ GUI status labels updated
✅ Both scanner and miner_v2 updated

**All peripheral references now use explicit naming for better reliability!** 🎯
