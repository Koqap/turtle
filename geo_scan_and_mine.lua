-- GEO SCAN AND MINE - Mining Turtle with Remote Scanner (v1.0 adapted)
-- FEATURES:
--   * Calls Geo Scanner via network peripheral
--   * Reads coordinates list
--   * Navigates via GPS
--   * Mines the target ores

local SCANNER_NAME = "geo_scanner_1"     -- adjust if needed
local REDNET_PROTOCOL = "geo_scan_results"  -- must match scanner broadcast
local COORDS_FILE = "scan_results.txt"

local TARGET_ORES = {
    "minecraft:coal_ore", "minecraft:deepslate_coal_ore", "minecraft:coal_block"
}

local stats = { scanned = 0, mined = 0, failed = 0 }

-- Helpers
local function isTarget(name)
    for _, t in ipairs(TARGET_ORES) do
        if name == t then return true end
    end
    return false
end

local function digForward()
    while turtle.detect() do turtle.dig() end
    while not turtle.forward() do turtle.attack() end
end

local function gotoPos(x, y, z)
    local cx, cy, cz = gps.locate()
    if not cx then
        print("ERROR: No GPS position!")
        return false
    end
    -- Vertical
    while cy < y do turtle.up(); cy = cy + 1 end
    while cy > y do turtle.down(); cy = cy - 1 end
    -- X
    if x > cx then
        turtle.setFacing("east")
        for i = 1, x - cx do digForward() end
    elseif x < cx then
        turtle.setFacing("west")
        for i = 1, cx - x do digForward() end
    end
    -- Z
    if z > cz then
        turtle.setFacing("south")
        for i = 1, z - cz do digForward() end
    elseif z < cz then
        turtle.setFacing("north")
        for i = 1, cz - z do digForward() end
    end
    return true
end

-- Read coords from file
local coords = {}
local f = fs.open(COORDS_FILE, "r")
if not f then
    print("ERROR: Could not open " .. COORDS_FILE)
    return
end
while true do
    local line = f.readLine()
    if not line then break end
    local x, y, z = line:match("(-?%d+) (-?%d+) (-?%d+)")
    if x and y and z then
        table.insert(coords, { x = tonumber(x), y = tonumber(y), z = tonumber(z) })
    end
end
f.close()

print("Loaded " .. #coords .. " target coordinates.")

-- Perform mining
for i, v in ipairs(coords) do
    print("Mining target " .. i .. "/" .. #coords .. " at (" .. v.x .. "," .. v.y .. "," .. v.z .. ")")
    if not gotoPos(v.x, v.y, v.z) then
        print("!! Failed to reach target.")
        stats.failed = stats.failed + 1
    else
        turtle.dig()
        turtle.digUp()
        turtle.digDown()
        stats.mined = stats.mined + 1
        print("✓ Mined target!")
    end
    sleep(0.2)
end

print("Mining complete!")
print("Mined: " .. stats.mined .. " targets; Failed: " .. stats.failed)
