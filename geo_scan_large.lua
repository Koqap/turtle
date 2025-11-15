-- GEO SCAN LARGE - Computer-based Scanner with Broadcast (v1.0)
-- FEATURES:
--  * Runs on main computer (not turtle)
--  * Wraps Geo Scanner peripheral directly
--  * Large radius scanning (48 blocks)
--  * Saves results to file
--  * Broadcasts results over rednet
--  * Filters for ores

-- ============ CONFIG ==============
local RADIUS = 48                    -- Large scan radius for caves
local SCANNER_NAME = "geo_scanner_0" -- Scanner peripheral name
local OUTPUT_FILE = "scan_results.txt"
local REDNET_PROTOCOL = "geo_scan_results"

-- Ore types to highlight
local ORE_TYPES = {
    "coal_ore",
    "iron_ore",
    "gold_ore",
    "diamond_ore",
    "emerald_ore",
    "copper_ore",
    "redstone_ore",
    "lapis_ore",
}

-- ============ STATE ==============
local stats = {
    total = 0,
    ores = 0,
    coal = 0,
}

-- ============ UTILITIES ==============
local function isOre(blockName)
    if not blockName then return false end
    for _, ore in ipairs(ORE_TYPES) do
        if string.find(blockName, ore) then
            return true
        end
    end
    return false
end

local function isCoal(blockName)
    if not blockName then return false end
    return string.find(blockName, "coal") ~= nil
end

-- ============ SCANNER SETUP ==============
local function findScanner()
    print("→ Looking for Geo Scanner...")

    local scanner = peripheral.wrap(SCANNER_NAME)
    if not scanner then
        print("ERROR: Scanner not found at " .. SCANNER_NAME)
        print("Make sure:")
        print("  1. Geo Scanner is connected via wired modem")
        print("  2. Wired modem is activated (right-click)")
        print("  3. Peripheral name is " .. SCANNER_NAME)
        return nil
    end

    -- Verify it has scan method
    if not scanner.scan then
        print("ERROR: Peripheral is not a Geo Scanner")
        return nil
    end

    print("✓ Geo Scanner found: " .. SCANNER_NAME)
    return scanner
end

-- ============ SCANNING ==============
local function performScan(scanner, radius)
    print(string.format("\n→ Scanning radius %d blocks...", radius))
    print("  This may take a moment for large radius...")

    local success, blocks = pcall(function()
        return scanner.scan(radius)
    end)

    if not success then
        print("ERROR: Scan failed")
        print("Error: " .. tostring(blocks))
        return nil
    end

    if not blocks or type(blocks) ~= "table" then
        print("ERROR: Invalid scan result")
        return nil
    end

    stats.total = #blocks
    print(string.format("✓ Scanned %d blocks", stats.total))

    return blocks
end

-- ============ FILTERING ==============
local function filterBlocks(blocks)
    print("\n→ Filtering blocks...")

    local ores = {}
    local coalOres = {}

    for _, block in ipairs(blocks) do
        if block.name then
            if isOre(block.name) then
                table.insert(ores, block)
                stats.ores = stats.ores + 1

                if isCoal(block.name) then
                    table.insert(coalOres, block)
                    stats.coal = stats.coal + 1
                end
            end
        end
    end

    print(string.format("  Ores found: %d", stats.ores))
    print(string.format("  Coal ores: %d", stats.coal))

    return ores, coalOres
end

-- ============ FILE OPERATIONS ==============
local function saveResults(blocks, ores, coalOres)
    print(string.format("\n→ Saving results to %s...", OUTPUT_FILE))

    local file = fs.open(OUTPUT_FILE, "w")
    if not file then
        print("ERROR: Could not open file for writing")
        return false
    end

    -- Write header
    file.writeLine("╔════════════════════════════════════════╗")
    file.writeLine("║  GEO SCANNER RESULTS                   ║")
    file.writeLine("╚════════════════════════════════════════╝")
    file.writeLine("")
    file.writeLine(string.format("Scan radius: %d blocks", RADIUS))
    file.writeLine(string.format("Total blocks: %d", stats.total))
    file.writeLine(string.format("Total ores: %d", stats.ores))
    file.writeLine(string.format("Coal ores: %d", stats.coal))
    file.writeLine("")
    file.writeLine("════════════════════════════════════════")
    file.writeLine("")

    -- Write coal ore locations
    if #coalOres > 0 then
        file.writeLine("COAL ORE LOCATIONS:")
        file.writeLine("")

        for i, ore in ipairs(coalOres) do
            local distance = math.sqrt(ore.x^2 + ore.y^2 + ore.z^2)
            file.writeLine(string.format("%d. %s", i, ore.name))
            file.writeLine(string.format("   X: %d  Y: %d  Z: %d", ore.x, ore.y, ore.z))
            file.writeLine(string.format("   Distance: %.1f blocks", distance))
            file.writeLine("")
        end

        file.writeLine("════════════════════════════════════════")
        file.writeLine("")
    end

    -- Write all ore locations
    if #ores > 0 then
        file.writeLine("ALL ORE LOCATIONS:")
        file.writeLine("")

        for i, ore in ipairs(ores) do
            local distance = math.sqrt(ore.x^2 + ore.y^2 + ore.z^2)
            file.writeLine(string.format("%d. %s", i, ore.name))
            file.writeLine(string.format("   X: %d  Y: %d  Z: %d", ore.x, ore.y, ore.z))
            file.writeLine(string.format("   Distance: %.1f blocks", distance))
            file.writeLine("")
        end
    end

    file.close()
    print(string.format("✓ Results saved to %s", OUTPUT_FILE))
    return true
end

-- ============ REDNET BROADCAST ==============
local function setupRednet()
    print("\n→ Setting up rednet broadcast...")

    -- Find modem
    local modem = peripheral.find("modem")
    if not modem then
        print("  No modem found - skipping broadcast")
        return false
    end

    -- Open rednet
    local success, err = pcall(function()
        rednet.open(peripheral.getName(modem))
    end)

    if not success then
        print("  Could not open rednet - skipping broadcast")
        return false
    end

    print("✓ Rednet ready on " .. peripheral.getName(modem))
    return true
end

local function broadcastResults(coalOres)
    print("\n→ Broadcasting results...")

    local success, err = pcall(function()
        rednet.broadcast({
            type = "scan_results",
            radius = RADIUS,
            total = stats.total,
            ores = stats.ores,
            coal = stats.coal,
            coalLocations = coalOres,
        }, REDNET_PROTOCOL)
    end)

    if not success then
        print("  Broadcast failed: " .. tostring(err))
        return false
    end

    print(string.format("✓ Results broadcast on protocol '%s'", REDNET_PROTOCOL))
    return true
end

-- ============ DISPLAY ==============
local function displayResults(coalOres)
    if #coalOres == 0 then
        print(string.format("\nNo coal ores found in radius %d", RADIUS))
        return
    end

    print("\n╔════════════════════════════════════════╗")
    print(string.format("║  FOUND %d COAL ORE(S)                  ", #coalOres))
    print("╚════════════════════════════════════════╝\n")

    -- Display first 10 coal ores
    local displayCount = math.min(10, #coalOres)
    for i = 1, displayCount do
        local ore = coalOres[i]
        local distance = math.sqrt(ore.x^2 + ore.y^2 + ore.z^2)

        print(string.format("%d. %s", i, ore.name))
        print(string.format("   X: %d  Y: %d  Z: %d", ore.x, ore.y, ore.z))
        print(string.format("   Distance: %.1f blocks\n", distance))
    end

    if #coalOres > 10 then
        print(string.format("... and %d more (see %s)\n", #coalOres - 10, OUTPUT_FILE))
    end
end

-- ============ MAIN ==============
print("╔════════════════════════════════════════╗")
print("║  GEO SCAN LARGE v1.0                   ║")
print("║  Computer-based Scanner                ║")
print("╚════════════════════════════════════════╝")
print(string.format("Scan radius: %d blocks", RADIUS))
print(string.format("Scanner: %s", SCANNER_NAME))
print("════════════════════════════════════════\n")

-- Find scanner
local scanner = findScanner()
if not scanner then
    print("\n✗ Scanner setup failed - exiting")
    return
end

-- Perform scan
local blocks = performScan(scanner, RADIUS)
if not blocks then
    print("\n✗ Scan failed - exiting")
    return
end

-- Filter blocks
local ores, coalOres = filterBlocks(blocks)

-- Save to file
saveResults(blocks, ores, coalOres)

-- Display results
displayResults(coalOres)

-- Setup rednet and broadcast
local rednetReady = setupRednet()
if rednetReady then
    broadcastResults(coalOres)
end

-- Final summary
print("\n╔════════════════════════════════════════╗")
print("║  SCAN COMPLETE!                        ║")
print("╚════════════════════════════════════════╝")
print(string.format("Total blocks scanned: %d", stats.total))
print(string.format("Total ores found: %d", stats.ores))
print(string.format("Coal ores found: %d", stats.coal))
print(string.format("Results saved to: %s", OUTPUT_FILE))
print("\n✓ Done!")
