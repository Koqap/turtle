-- GEO SCAN LARGE - Computer-based Scanner with Broadcast (v1.0 adapted)
-- FEATURES:
--   * Runs on main computer (not turtle)
--   * Wraps Geo Scanner peripheral directly
--   * Handles a safe radius for your version
--   * Saves results to file
--   * Broadcasts results over rednet

local RADIUS = 20  -- safe for your version (adjust up to 16-20)
local SCANNER_NAME = "geo_scanner_1"  -- adjust if yours differs
local OUTPUT_FILE = "scan_results.txt"
local REDNET_PROTOCOL = "geo_scan_results"

local ORE_TYPES = {
    "coal_ore", "deepslate_coal_ore",
    "iron_ore", "gold_ore", "diamond_ore", "emerald_ore",
    "copper_ore", "redstone_ore", "lapis_ore",
}

local stats = { total = 0, ores = 0, coal = 0 }

local function isOre(name)
    if not name then return false end
    for _, ore in ipairs(ORE_TYPES) do
        if string.find(name, ore) then
            return true
        end
    end
    return false
end

local function isCoal(name)
    if not name then return false end
    return string.find(name, "coal") ~= nil
end

local function findScanner()
    print("→ Looking for Geo Scanner...")
    local scanner = peripheral.wrap(SCANNER_NAME)
    if not scanner or not scanner.scan then
        print("ERROR: Scanner not found at " .. SCANNER_NAME)
        print(" Make sure:")
        print("  1. Geo Scanner connected via wired modem")
        print("  2. Wired modem is activated")
        print("  3. Peripheral name is " .. SCANNER_NAME)
        return nil
    end
    print("✓ Geo Scanner found: " .. SCANNER_NAME)
    return scanner
end

local function performScan(scanner, radius)
    print("\n→ Scanning radius " .. radius .. " blocks...")
    local success, blocks = pcall(function() return scanner.scan(radius) end)
    if not success or not blocks or type(blocks) ~= "table" then
        print("ERROR: Scan failed or invalid result")
        return nil
    end
    stats.total = #blocks
    print("✓ Scanned " .. stats.total .. " blocks")
    return blocks
end

local function filterBlocks(blocks)
    print("\n→ Filtering blocks for ores and coal...")
    local oresList, coalList = {}, {}
    for _, b in ipairs(blocks) do
        if b.name and isOre(b.name) then
            table.insert(oresList, b)
            stats.ores = stats.ores + 1
            if isCoal(b.name) then
                table.insert(coalList, b)
                stats.coal = stats.coal + 1
            end
        end
    end
    print(" Ore count: " .. stats.ores)
    print(" Coal count: " .. stats.coal)
    return oresList, coalList
end

local function saveResults(oresList, coalList)
    print("\n→ Saving results to " .. OUTPUT_FILE)
    local f = fs.open(OUTPUT_FILE, "w")
    if not f then
        print("ERROR: Could not open file for writing")
        return false
    end
    -- Write minimal machine-readable format (just coordinates)
    for _, ore in ipairs(coalList) do
        f.write(ore.x .. " " .. ore.y .. " " .. ore.z .. "\n")
    end
    f.close()
    print("✓ Results saved to " .. OUTPUT_FILE)
    return true
end

local function broadcastResults(coalList)
    local modem = peripheral.find("modem")
    if not modem then return false end
    rednet.open(peripheral.getName(modem))
    rednet.broadcast({ type = "coal_coords", coords = coalList }, REDNET_PROTOCOL)
    print("✓ Results broadcast on protocol '" .. REDNET_PROTOCOL .. "'")
    return true
end

-- === MAIN ===
print("=== GEO SCAN LARGE v1.0 (adapted) ===")
local scanner = findScanner()
if not scanner then return end
local blocks = performScan(scanner, RADIUS)
if not blocks then return end
local oresList, coalList = filterBlocks(blocks)
if #coalList == 0 then
    print("No coal ores found in radius " .. RADIUS)
    return
end
saveResults(oresList, coalList)
broadcastResults(coalList)
print("\nDone!")
