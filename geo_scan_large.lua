-- GEO SCAN LARGE (16-radius) – Wireless Broadcast Version
local SCAN_RADIUS = 16
local PROTOCOL = "geo_scan_results"

-- Use the scanner peripheral with explicit name
local scanner = peripheral.wrap("geo_scanner_1")
if not scanner then
    print("ERROR: geo_scanner_1 not found!")
    return
end

-- Find any modem for broadcasting
local modem = peripheral.find("modem")
if not modem then
    print("ERROR: No modem found!")
    return
end

rednet.open(peripheral.getName(modem))

print("Scanning radius:", SCAN_RADIUS, "blocks...")
local data = scanner.scan(SCAN_RADIUS)

-- Check that data is a table
if type(data) ~= "table" then
    print("ERROR: Scan failed or returned invalid result:", tostring(data))
    return
end

print("Scan complete! Filtering coal...")

local coal = {}
for _, b in ipairs(data) do
    if b.name == "minecraft:coal_ore"
    or b.name == "minecraft:deepslate_coal_ore" then
        table.insert(coal, { x = b.x, y = b.y, z = b.z })
    end
end

print("Coal found:", #coal)

print("Broadcasting results...")
rednet.broadcast(coal, PROTOCOL)

print("Done!")
