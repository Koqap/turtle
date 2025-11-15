-- GEO SCAN LARGE (16-radius) - Wireless Broadcast Version

local SCAN_RADIUS = 16
local PROTOCOL = "geo_scan_results"

-- Find GeoScanner peripheral
local scanner = peripheral.find("geoScanner")
if not scanner then
    print("ERROR: No GeoScanner found!")
    return
end

-- Open wireless modem
local modemSide = peripheral.find("modem")
if not modemSide then
    print("ERROR: No modem attached!")
    return
end

rednet.open(peripheral.getName(modemSide))

print("Scanning radius:", SCAN_RADIUS, "blocks...")
local results = scanner.scan(SCAN_RADIUS)

if not results then
    print("Scan failed!")
    return
end

print("Scan complete! Processing coal ores...")

local coal = {}
for _, b in ipairs(results) do
    if b.name == "minecraft:coal_ore"
    or b.name == "minecraft:deepslate_coal_ore" then
        table.insert(coal, { x = b.x, y = b.y, z = b.z })
    end
end

print("Coal ores found:", #coal)

-- Broadcast the coal coordinates to all turtles
rednet.broadcast(coal, PROTOCOL)

print("Broadcast complete!")
print("Turtles may now begin mining.")
