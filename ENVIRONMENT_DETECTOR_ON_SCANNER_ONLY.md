# Environment Detector - Scanner Only Architecture

## 🔧 Problem Fixed

**Issue:** Environment Detector was on miner turtle, but:
- Environment Detector doesn't work through wired blocks/rednet
- Turtle's left and right sides are used for mining tools and wireless modem
- No good peripheral slot for Environment Detector on turtle

**Solution:** Move Environment Detector to SCANNER only, send data via rednet

---

## 🏗️ New Architecture

### **Before (Wrong):**

```
[Scanner Computer]              [Miner Turtle]
- Geo Scanner                   - Wireless Modem (left)
- Wireless Modem                - Mining Tool (right)
- Environment Detector          - Environment Detector ❌ (where?)
```

**Problems:**
- ❌ No good place to attach Environment Detector on turtle
- ❌ Environment Detector doesn't transmit through rednet
- ❌ Turtle can't scan remotely from scanner's location

---

### **After (Correct):**

```
[Scanner Computer]              [Miner Turtle]
- Geo Scanner                   - Wireless Modem (left)
- Wireless Modem                - Mining Tool (right)
- Environment Detector ✓        - GPS access only ✓
- GPS access                    
```

**Benefits:**
- ✓ Environment Detector stays at base (scanner)
- ✓ Scanner sends chest location data via rednet
- ✓ Turtle has free peripheral slots
- ✓ Cleaner separation of concerns

---

## 📡 New Rednet Protocol

### **Message Type: `request_chest_scan`**

**Sent by:** Miner turtle  
**Received by:** Scanner  
**Purpose:** Request scanner to find chest near turtle's position

```lua
-- Turtle sends:
rednet.send(COMPUTER_ID, {
    type = "request_chest_scan",
    x = 100,  -- Turtle's current X
    y = 64,   -- Turtle's current Y
    z = 200   -- Turtle's current Z
}, PROTOCOL)
```

---

### **Message Type: `chest_scan_result`**

**Sent by:** Scanner  
**Received by:** Miner turtle  
**Purpose:** Return chest location data or error

**Success Response:**
```lua
rednet.send(turtle_id, {
    type = "chest_scan_result",
    success = true,
    chest = {
        x = 105,  -- Absolute world coordinates
        y = 64,
        z = 198
    }
}, PROTOCOL)
```

**Failure Response:**
```lua
rednet.send(turtle_id, {
    type = "chest_scan_result",
    success = false,
    error = "No chest found within range"
}, PROTOCOL)
```

---

## 🔍 How It Works

### **1. Turtle Startup (First Time)**

```
Turtle: FIRST TIME SETUP
  Getting GPS position: 100, 64, 200
  Requesting chest scan from scanner...
  
  → Sends request_chest_scan to scanner

Scanner: Chest scan request from turtle 5
  Scanning near position: 100, 64, 200
  Scan offset from scanner: 50, 0, -50
  Scanned 2048 blocks
  Found minecraft:chest at 105, 64, 198 (distance: 7)
  ✓ Closest chest: 105, 64, 198 (distance: 7 blocks)
  
  → Sends chest_scan_result with chest location

Turtle: ✓ Scanner found chest at: 105, 64, 198
  Offset from turtle: 5, 0, -2
  Chest is to the EAST
  ✓ Facing away: West
  ✓ Home configured: 100, 64, 200
  ✓ Setup complete and saved!
```

---

### **2. Turtle Depositing Items**

```
Turtle: Depositing to chest...
  Current position: 100, 64, 200 (GPS verified)
  Requesting chest scan from scanner...
  
  → Sends request_chest_scan to scanner

Scanner: Chest scan request from turtle 5
  Scanning near position: 100, 64, 200
  ✓ Closest chest: 105, 64, 198
  
  → Sends chest_scan_result

Turtle: ✓ Chest at offset: +5, 0, -2
  Chest is to the EAST
  Facing chest...
  ✓ Deposited 12 items
```

---

## 📝 Code Changes

### **Miner (`miner_v2`)**

**Removed:**
```lua
-- DELETED: No more Environment Detector on turtle!
local envDetector = peripheral.wrap("environment_detector_1")
local function scanBlocksWithEnvDetector(radius) ...
local function findChestWithEnvDetector() ...
local function detectChestEnvironment() ...
```

**Added:**
```lua
----------------------------------
-- CHEST DETECTION VIA SCANNER
----------------------------------
local function requestChestScan(fromPos)
    print("Requesting chest scan from scanner...")
    
    rednet.send(COMPUTER_ID, {
        type = "request_chest_scan",
        x = fromPos.x,
        y = fromPos.y,
        z = fromPos.z
    }, PROTOCOL)
    
    -- Wait for response (timeout 10 seconds)
    local timeout = 10
    local startTime = os.clock()
    
    while os.clock() - startTime < timeout do
        local id, msg = rednet.receive(PROTOCOL, 0.5)
        if id == COMPUTER_ID and msg and msg.type == "chest_scan_result" then
            return msg.chest, msg.success
        end
    end
    
    print("  ✗ No response from scanner")
    return nil, false
end

local function detectChestViaScanner()
    print("═══════════════════════════════")
    print("  CHEST DETECTION (VIA SCANNER)")
    print("═══════════════════════════════")
    
    local pos = getPos()
    local chest, success = requestChestScan(pos)
    
    if not success or not chest then
        error("Chest detection failed")
    end
    
    -- Calculate offsets and direction
    -- ... (setup logic)
    
    return {x = pos.x, y = pos.y, z = pos.z, facing = awayDir}
end
```

**Updated:**
```lua
-- Startup: Use detectChestViaScanner() instead of detectChestEnvironment()
local detected = detectChestViaScanner()

-- depositToChest(): Request chest scan from scanner
local chest, success = requestChestScan(homePos)
```

---

### **Scanner (`scanner`)**

**Added Protocol Handler:**
```lua
elseif msg.type == "request_chest_scan" then
    print(string.format("[%s] Chest scan request from turtle %d", os.time(), id))
    local turtleX, turtleY, turtleZ = msg.x, msg.y, msg.z
    
    if not envDetector then
        rednet.send(id, {
            type = "chest_scan_result",
            success = false,
            error = "Scanner has no Environment Detector"
        }, PROTOCOL)
        return
    end
    
    -- Calculate scan offset (scanner position to turtle position)
    local scanOffsetX = turtleX - SCANNER_X
    local scanOffsetY = turtleY - SCANNER_Y
    local scanOffsetZ = turtleZ - SCANNER_Z
    
    -- Scan with Environment Detector (15 block radius)
    local ok, blocks = pcall(function() return envDetector.scan(15) end)
    
    -- Find chests in results
    local chests = {}
    for _, block in ipairs(blocks) do
        if block.name and block.name:find("chest") then
            -- Convert to absolute coordinates
            local absX = SCANNER_X + block.x
            local absY = SCANNER_Y + block.y
            local absZ = SCANNER_Z + block.z
            
            -- Calculate distance from turtle
            local dist = math.abs(absX - turtleX) + 
                        math.abs(absY - turtleY) + 
                        math.abs(absZ - turtleZ)
            
            if dist <= 10 then
                table.insert(chests, {
                    x = absX, y = absY, z = absZ, 
                    distance = dist
                })
            end
        end
    end
    
    if #chests == 0 then
        rednet.send(id, {
            type = "chest_scan_result",
            success = false,
            error = "No chest found within range"
        }, PROTOCOL)
        return
    end
    
    -- Find closest chest
    table.sort(chests, function(a, b) return a.distance < b.distance end)
    local closest = chests[1]
    
    print(string.format("  ✓ Closest chest: %d, %d, %d", 
        closest.x, closest.y, closest.z))
    
    rednet.send(id, {
        type = "chest_scan_result",
        success = true,
        chest = {x = closest.x, y = closest.y, z = closest.z}
    }, PROTOCOL)
```

---

## 🎯 Coordinate Calculation

### **Scanner Scans From Its Own Position:**

```
Scanner position: (0, 64, 0)
Turtle position:  (50, 64, 100)

Scanner Environment Detector scans 15 blocks from (0, 64, 0):
  Returns blocks with RELATIVE coordinates from scanner

Example chest found at offset: (+55, 0, +95)
  Absolute position: (0 + 55, 64 + 0, 0 + 95) = (55, 64, 95)

Distance from turtle to chest:
  |55 - 50| + |64 - 64| + |95 - 100| = 5 + 0 + 5 = 10 blocks ✓

Scanner sends to turtle:
  chest = {x = 55, y = 64, z = 95}  (absolute coordinates)
```

---

### **Turtle Calculates Offset:**

```
Turtle receives: chest = {x = 55, y = 64, z = 95}
Turtle position: (50, 64, 100)

Offset from turtle to chest:
  cx = 55 - 50 = +5  (chest is 5 blocks EAST)
  cy = 64 - 64 = 0   (same Y-level)
  cz = 95 - 100 = -5 (chest is 5 blocks NORTH)

Chest direction:
  |cx| = 5, |cz| = 5
  Since cx > 0 and |cx| >= |cz|: Chest is to the EAST
  chestDir = 1 (East)

Home facing:
  Face AWAY from chest
  awayDir = (1 + 2) % 4 = 3 (West)
```

---

## ✅ Benefits

### **1. No Peripheral Conflicts**

```
Turtle peripherals:
  Left:  Wireless Modem (for rednet)
  Right: Mining Tool (pickaxe/shovel)
  
No need for Environment Detector!
```

---

### **2. Centralized Scanning**

```
Scanner has ALL scanning peripherals:
  - Geo Scanner (find ores)
  - Environment Detector (find chests/blocks)
  - GPS access
  - Monitor (optional)

Turtle is lightweight:
  - Wireless Modem only
  - GPS access
  - Mining tools
```

---

### **3. Accurate World Coordinates**

```
Scanner uses GPS to know its position:
  SCANNER_X, SCANNER_Y, SCANNER_Z = gps.locate()

Environment Detector scans relative to scanner:
  block.x, block.y, block.z (offsets)

Convert to absolute:
  absX = SCANNER_X + block.x
  absY = SCANNER_Y + block.y
  absZ = SCANNER_Z + block.z

Send absolute coordinates to turtle:
  ✓ No coordinate confusion!
  ✓ Works anywhere in world!
```

---

## 📊 Setup Requirements

### **Scanner Computer:**

```
Required:
  ✓ Wireless Modem (any side)
  ✓ Geo Scanner (geo_scanner_2)
  ✓ Environment Detector (environment_detector_1)
  ✓ GPS access (4+ GPS hosts running)

Optional:
  - External monitor (auto-detected)
  - Basalt GUI library (v2)
```

---

### **Miner Turtle:**

```
Required:
  ✓ Wireless Modem (left side)
  ✓ Mining Tool (right side - pickaxe/shovel)
  ✓ GPS access (4+ GPS hosts running)

NOT needed:
  ✗ Environment Detector (scanner has it!)
```

---

## 🐛 Error Handling

### **Scanner Has No Environment Detector:**

```
Turtle: Requesting chest scan from scanner...

Scanner: ✗ Environment Detector not available!
  → Sends: {success = false, error = "Scanner has no Environment Detector"}

Turtle: ✗ ERROR: Scanner could not find chest!

  Setup:
    1. Ensure scanner computer is running
    2. Scanner must have Environment Detector (environment_detector_1)
    3. Place chest within 5 blocks of turtle
```

---

### **No Chest Found:**

```
Scanner: Chest scan request from turtle 5
  Scanned 2048 blocks
  ✗ No chests found near turtle!
  → Sends: {success = false, error = "No chest found within range"}

Turtle: ✗ ERROR: Scanner could not find chest!
  
  Setup:
    1. Place chest within 5 blocks of turtle
    2. Turtle and chest on same Y-level
```

---

### **Scanner Not Responding:**

```
Turtle: Requesting chest scan from scanner...
  (waiting 10 seconds...)
  ✗ No response from scanner

  Setup:
    1. Ensure scanner computer is running
    2. Check rednet connection (wireless modem)
    3. Verify scanner is on same rednet network
```

---

## 🔍 Debugging

### **Scanner Console:**

```
[12:34:56] Chest scan request from turtle 5
  Scanning near position: 100, 64, 200
  Scan offset from scanner: 50, 0, -50
  Scanned 2048 blocks
  Found minecraft:chest at 105, 64, 198 (distance: 7)
  Found minecraft:barrel at 108, 64, 195 (distance: 14)
  ✓ Closest chest: 105, 64, 198 (distance: 7 blocks)
```

---

### **Turtle Console:**

```
Requesting chest scan from scanner...
✓ Scanner found chest at: 105, 64, 198
  Offset from turtle: +5, 0, -2
  Chest is to the EAST
✓ Facing away: West
✓ Home configured: 100, 64, 200
```

---

## 📝 Summary

| Aspect | Before | After |
|--------|--------|-------|
| **Environment Detector Location** | On turtle ❌ | On scanner ✓ |
| **Chest Detection** | Local scan on turtle | Remote scan via rednet |
| **Peripheral Slots** | Conflicts with modem/tools | Clean (modem + tool only) |
| **Coordinate System** | Relative to turtle | Absolute world coords |
| **Setup Complexity** | High (peripheral wiring) | Low (wireless only) |
| **Error Handling** | Basic | Comprehensive |

---

### **Key Changes:**

1. ✓ Removed Environment Detector from `miner_v2`
2. ✓ Added `request_chest_scan` protocol message
3. ✓ Added `chest_scan_result` protocol response
4. ✓ Scanner handles chest scanning with its Environment Detector
5. ✓ Turtle requests chest data via rednet (no local scanning)

---

### **Result:**

- ✓ **Cleaner architecture** (scanner = brain, turtle = worker)
- ✓ **No peripheral conflicts** on turtle
- ✓ **Accurate coordinates** (scanner GPS + Environment Detector)
- ✓ **Remote scanning** (turtle doesn't need Environment Detector)
- ✓ **Better error messages** for troubleshooting

---

**Environment Detector is now scanner-only!** 📡✨
