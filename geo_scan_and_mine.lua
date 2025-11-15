-- GEO SCAN AND MINE - Mining Turtle with Remote Scanner (v1.0)
-- FEATURES:
--  * Remotely calls Geo Scanner via network
--  * GPS navigation to ore locations
--  * Mines coal ores automatically
--  * Large radius scanning (48 blocks)
--  * Handles GPS failures gracefully

-- ============ CONFIG ==============
local RADIUS = 48                    -- Large scan radius for caves
local SCANNER_NAME = "geo_scanner_0" -- Scanner peripheral on network
local REDNET_PROTOCOL = "geo_mining" -- Rednet protocol

-- Target ores to mine
local TARGET_ORES = {
    "minecraft:coal_ore",
    "minecraft:deepslate_coal_ore",
    "minecraft:coal_block",
}

-- ============ STATE ==============
local stats = {
    scanned = 0,
    mined = 0,
    failed = 0,
}

-- Current GPS position
local gpsPos = nil

-- ============ UTILITIES ==============
local function isTargetOre(blockName)
    if not blockName then return false end
    for _, name in ipairs(TARGET_ORES) do
        if name == blockName then return true end
    end
    return false
end

-- ============ REDNET SETUP ==============
local function setupRednet()
    print("→ Setting up rednet...")

    -- Find wireless modem
    local modem = peripheral.find("modem", function(name, wrapped)
        return wrapped.isWireless()
    end)

    if not modem then
        print("ERROR: No wireless modem found")
        return false
    end

    -- Open rednet
    rednet.open(peripheral.getName(modem))
    print("✓ Rednet opened on " .. peripheral.getName(modem))
    return true
end

-- ============ GPS ==============
local function getGPSPosition()
    print("→ Getting GPS position...")
    local x, y, z = gps.locate(5)

    if not x then
        print("ERROR: GPS not available")
        print("Make sure GPS satellites are set up")
        return nil
    end

    print(string.format("✓ GPS: X=%d Y=%d Z=%d", x, y, z))
    return {x = math.floor(x), y = math.floor(y), z = math.floor(z)}
end

-- ============ SCANNING ==============
local function scanForOres()
    print(string.format("\n→ Scanning radius %d blocks...", RADIUS))
    print("  Using remote scanner: " .. SCANNER_NAME)

    local success, result = pcall(function()
        return peripheral.call(SCANNER_NAME, "scan", RADIUS)
    end)

    if not success then
        print("ERROR: Failed to call scanner")
        print("Error: " .. tostring(result))
        print("Make sure:")
        print("  1. Geo Scanner is connected to network")
        print("  2. Scanner peripheral name is " .. SCANNER_NAME)
        print("  3. Wired modem is on the scanner")
        return {}
    end

    if not result or type(result) ~= "table" then
        print("ERROR: Invalid scan result")
        return {}
    end

    stats.scanned = #result
    print(string.format("✓ Scanned %d blocks", stats.scanned))

    -- Filter for target ores
    local ores = {}
    for _, block in ipairs(result) do
        if block.name and isTargetOre(block.name) then
            table.insert(ores, {
                name = block.name,
                x = block.x or 0,
                y = block.y or 0,
                z = block.z or 0,
            })
        end
    end

    return ores
end

-- ============ NAVIGATION ==============
local function digForward()
    local attempts = 0
    while not turtle.forward() do
        if turtle.detect() then
            turtle.dig()
        end
        turtle.attack()
        attempts = attempts + 1
        if attempts > 10 then
            return false
        end
        sleep(0.3)
    end
    return true
end

local function digUp()
    local attempts = 0
    while not turtle.up() do
        if turtle.detectUp() then
            turtle.digUp()
        end
        turtle.attackUp()
        attempts = attempts + 1
        if attempts > 10 then
            return false
        end
        sleep(0.3)
    end
    return true
end

local function digDown()
    local attempts = 0
    while not turtle.down() do
        if turtle.detectDown() then
            turtle.digDown()
        end
        turtle.attackDown()
        attempts = attempts + 1
        if attempts > 10 then
            return false
        end
        sleep(0.3)
    end
    return true
end

local function turnToFacing(targetFacing)
    -- Facing: 0=North(-Z), 1=East(+X), 2=South(+Z), 3=West(-X)
    -- Simplified: just turn right until we estimate correct direction
    -- This is a basic implementation - proper GPS heading detection would be better
    local currentFacing = 0  -- Assume starting north

    while currentFacing ~= targetFacing do
        turtle.turnRight()
        currentFacing = (currentFacing + 1) % 4
    end
end

local function goto(targetX, targetY, targetZ)
    if not gpsPos then
        print("ERROR: No GPS position - cannot navigate")
        return false
    end

    print(string.format("→ Navigating to (%d, %d, %d)", targetX, targetY, targetZ))

    -- Move Y first (vertical)
    local dy = targetY - gpsPos.y
    if dy > 0 then
        for i = 1, dy do
            if not digUp() then
                print("!! Failed to move up")
                return false
            end
            gpsPos.y = gpsPos.y + 1
        end
    elseif dy < 0 then
        for i = 1, -dy do
            if not digDown() then
                print("!! Failed to move down")
                return false
            end
            gpsPos.y = gpsPos.y - 1
        end
    end

    -- Move X
    local dx = targetX - gpsPos.x
    if dx ~= 0 then
        -- Face east (+X) or west (-X)
        local facing = dx > 0 and 1 or 3
        turnToFacing(facing)

        for i = 1, math.abs(dx) do
            if not digForward() then
                print("!! Failed to move in X")
                return false
            end
            gpsPos.x = gpsPos.x + (dx > 0 and 1 or -1)
        end
    end

    -- Move Z
    local dz = targetZ - gpsPos.z
    if dz ~= 0 then
        -- Face south (+Z) or north (-Z)
        local facing = dz > 0 and 2 or 0
        turnToFacing(facing)

        for i = 1, math.abs(dz) do
            if not digForward() then
                print("!! Failed to move in Z")
                return false
            end
            gpsPos.z = gpsPos.z + (dz > 0 and 1 or -1)
        end
    end

    print("✓ Arrived at destination")
    return true
end

-- ============ MINING ==============
local function mineOre(ore)
    print(string.format("\n→ Mining: %s", ore.name))
    print(string.format("  Location: (%d, %d, %d)", ore.x, ore.y, ore.z))

    -- Calculate absolute coordinates
    local targetX = gpsPos.x + ore.x
    local targetY = gpsPos.y + ore.y
    local targetZ = gpsPos.z + ore.z

    -- Navigate to ore
    if not goto(targetX, targetY, targetZ) then
        print("!! Failed to reach ore")
        stats.failed = stats.failed + 1
        return false
    end

    -- Mine the ore (dig in all directions)
    turtle.dig()
    turtle.digUp()
    turtle.digDown()

    -- Turn and mine all sides
    for i = 1, 4 do
        turtle.dig()
        turtle.turnRight()
    end

    stats.mined = stats.mined + 1
    print("✓ Ore mined!")
    return true
end

-- ============ MAIN ==============
print("╔════════════════════════════════════════╗")
print("║  GEO SCAN AND MINE v1.0                ║")
print("║  Remote Scanner + GPS Mining           ║")
print("╚════════════════════════════════════════╝")
print(string.format("Scan radius: %d blocks", RADIUS))
print(string.format("Scanner: %s", SCANNER_NAME))
print("════════════════════════════════════════\n")

-- Setup
if not setupRednet() then
    print("✗ Rednet setup failed - exiting")
    return
end

gpsPos = getGPSPosition()
if not gpsPos then
    print("✗ GPS not available - exiting")
    print("This program requires GPS for navigation")
    return
end

-- Scan for ores
local ores = scanForOres()

if #ores == 0 then
    print(string.format("\nNo coal ores found in radius %d", RADIUS))
    print("✓ Scan complete - nothing to mine")
    return
end

print(string.format("\n╔════════════════════════════════════════╗"))
print(string.format("║  FOUND %d COAL ORE(S)                  ", #ores))
print(string.format("╚════════════════════════════════════════╝\n"))

-- Display all ores
for i, ore in ipairs(ores) do
    local absX = gpsPos.x + ore.x
    local absY = gpsPos.y + ore.y
    local absZ = gpsPos.z + ore.z
    local distance = math.sqrt(ore.x^2 + ore.y^2 + ore.z^2)

    print(string.format("%d. %s", i, ore.name))
    print(string.format("   Relative: (%d, %d, %d)", ore.x, ore.y, ore.z))
    print(string.format("   Absolute: (%d, %d, %d)", absX, absY, absZ))
    print(string.format("   Distance: %.1f blocks\n", distance))
end

-- Confirm before mining
print("Press any key to start mining, or Ctrl+T to cancel...")
os.pullEvent("key")

-- Mine each ore
print("\n🔨 Starting mining operation...\n")
for i, ore in ipairs(ores) do
    print(string.format("═══ Mining %d/%d ═══", i, #ores))
    mineOre(ore)
    sleep(0.5)
end

-- Final stats
print("\n╔════════════════════════════════════════╗")
print("║  MINING COMPLETE!                      ║")
print("╚════════════════════════════════════════╝")
print(string.format("Blocks scanned: %d", stats.scanned))
print(string.format("Ores found: %d", #ores))
print(string.format("Ores mined: %d", stats.mined))
print(string.format("Failed: %d", stats.failed))
print("\n✓ Done!")
