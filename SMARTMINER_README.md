# SmartMiner System

A sophisticated Computer + Turtle mining system with real-time pathfinding, GUI visualization, and persistent map storage.

## Architecture

### Computer Brain (`scanner`)
- **Advanced Computer** with Geo Scanner, Wireless Modem, and Memory Card
- **Basalt GUI** for real-time map visualization
- **A* Pathfinding** for optimal route calculation
- **Map Persistence** via Memory Card
- Request-response protocol for turtle coordination

### Miner Turtle (`miner_v2`)
- **GPS-based positioning** for accurate navigation
- **Smart pathfinding** that uses existing caves/paths
- **Inventory management** with automatic chest deposits
- **Fuel management** with automatic refueling
- Request-based protocol for coordinated mining

## Setup Instructions

### 1. Computer Brain Setup

**Hardware Requirements:**
- Advanced Computer
- Geo Scanner (attach to right side)
- Wireless Modem (attach to top)
- Memory Card (attach to back)

**Software Requirements:**
```bash
# Install Basalt GUI framework
wget run https://basalt.madefor.cc/install.lua
```

**Installation:**
1. Copy the `scanner` script to the Advanced Computer
2. Edit the script to configure:
   - `scannerSide` - side with Geo Scanner (default: "right")
   - `modemSide` - side with wireless modem (default: "top")
   - `memorySide` - side with Memory Card (default: "back")
   - `SCAN_RADIUS` - scanning radius (default: 8)
   - `BASALT` - set to true if Basalt is installed
3. Run the script: `scanner`

### 2. Miner Turtle Setup

**Hardware Requirements:**
- Mining Turtle (or Wireless Mining Turtle)
- Wireless Modem
- GPS system in range
- Chest for deposit

**Installation:**
1. Copy the `miner_v2` script to the turtle
2. Place a chest BEHIND the turtle
3. Edit the script to configure:
   - `COMPUTER_ID` - ID of the computer brain (default: 1)
   - `PROTOCOL` - must match computer (default: "smartminer")
4. Run the script: `miner_v2`
5. Follow the setup prompts:
   - Press ENTER when chest is in place
   - Turtle will detect facing direction
   - Turtle will request initial scan

## Protocol

### Message Types

**From Turtle to Computer:**
- `request_scan` - Request geo scan at turtle's location
  ```lua
  {type="request_scan", x=x, y=y, z=z}
  ```
- `request_path` - Request path to nearest ore
  ```lua
  {type="request_path", x=x, y=y, z=z}
  ```
- `ore_mined` - Report mined ore
  ```lua
  {type="ore_mined", x=x, y=y, z=z}
  ```

**From Computer to Turtle:**
- `scan_result` - Scan results with ore list
  ```lua
  {type="scan_result", ores={...}, scanned=n}
  ```
- `path` - Pathfinding result
  ```lua
  {type="path", steps={{x,y,z},...}, target={x,y,z,name}}
  ```
- `ack` - Acknowledgment
  ```lua
  {type="ack", remaining=n}
  ```

## Features

### Computer Brain Features
- ✓ **Basalt GUI** with map visualization
- ✓ **A* Pathfinding** for 3D navigation
- ✓ **Map Persistence** via Memory Card
- ✓ **Real-time ore tracking** with claimed/unclaimed status
- ✓ **Multi-ore support** (coal, iron, gold, diamond, emerald, redstone, lapis, copper)
- ✓ **Deepslate variant support**
- ✓ **Auto-save** every 30 seconds
- ✓ **Request-response protocol** for coordinated mining

### Miner Turtle Features
- ✓ **GPS-based navigation** for absolute positioning
- ✓ **Smart movement** that prefers existing paths/caves
- ✓ **Automatic chest deposits** when inventory is full
- ✓ **Smart fuel management** with inventory refueling
- ✓ **Path execution** from computer brain
- ✓ **Statistics tracking** (moves, blocks mined, efficiency)
- ✓ **Idle detection** with automatic re-scanning
- ✓ **Continuous operation** until Ctrl+T

## GUI Controls

**Computer Brain (with Basalt):**
- **Map Window** (left) - Shows top-down 2D view
  - `H` = Home position
  - `*` = Ore location
  - `.` = Visited location
  - `#` = Known block
  - ` ` = Unknown/air
- **Panel** (right) - Shows ore list and status
- **Status Bar** - Shows computer ID, protocol, ore count
- **Log Area** - Shows recent activity
- **Press Q** to quit and save

## Configuration

### Computer Brain Variables
```lua
local scannerSide = "right"          -- Geo Scanner side
local modemSide = "top"              -- Wireless modem side
local memorySide = "back"            -- Memory Card side
local BASALT = true                  -- Enable GUI
local SCAN_RADIUS = 8                -- Scanner radius
local MAP_SAVE_KEY = "minerMap"      -- Memory card key
local AUTO_SAVE_INTERVAL = 30        -- Auto-save seconds
local PROTOCOL = "smartminer"        -- Rednet protocol
```

### Miner Turtle Variables
```lua
local PROTOCOL = "smartminer"        -- Must match computer
local COMPUTER_ID = 1                -- Computer brain ID
local modemSide = "right"            -- Wireless modem side
```

## Usage Tips

1. **Start computer brain first** - It must be running to handle turtle requests
2. **GPS is required** - Ensure GPS system covers mining area
3. **Fuel management** - Keep coal/charcoal in turtle inventory
4. **Multiple turtles** - System supports multiple turtles (each makes requests)
5. **Scan radius** - Increase for larger coverage, decrease for performance
6. **Map persistence** - Map data survives computer restarts
7. **Basalt optional** - Works in text mode if Basalt not installed

## Troubleshooting

**Computer Brain:**
- "geo_scanner not found" - Check scanner peripheral side
- "modem not found" - Check wireless modem side
- "Basalt not available" - Install Basalt or set BASALT=false

**Miner Turtle:**
- "No wireless modem" - Attach wireless modem
- "GPS signal required" - Ensure GPS coverage
- "No chest found" - Place chest behind turtle
- "GPS signal lost" - Move to area with GPS coverage

## Statistics

**Turtle tracks:**
- Ores mined
- Total moves
- Free moves (no digging required)
- Blocks mined (forward, up, down)
- Movement efficiency
- Scans requested
- Paths received

## Advanced Features

### A* Pathfinding
- 3D navigation with obstacle avoidance
- Avoids lava, water, and bedrock
- Manhattan distance heuristic
- Efficient path reconstruction

### Map Persistence
- Stores visited locations
- Tracks all scanned blocks
- Maintains ore database
- Auto-saves every 30 seconds
- Survives computer restarts

### Smart Movement
- Tries movement before digging
- Uses existing caves and paths
- Tracks movement statistics
- Minimizes block breaking

## Version
SmartMiner System v1.0 - Computer Crafted Edition
