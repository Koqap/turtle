-- === GEO SCAN BLOCK VERSION (geo_scanner_1 ONLY) ===

local SCAN_RADIUS = 16
local PROTOCOL = "geo_scan_results"

-- Force use of EXACT peripheral name
local scanner = peripheral.wrap("geo_scanner_1")
if not scanner then
    print("ERROR: geo_scanner_1 not found!")
    return
end

-- Find ANY modem for broadcasting
local modem = peripheral.find("modem")
if not modem then
    print("ERROR: No modem found!")
    return
end

rednet.open(peripheral.getName(modem))

print("Scanning radius:", SCAN_RADIUS)
local data = scanner.scanBlocks(SCAN_RADIUS)

if not data then
    print("ERROR: scanBlocks failed")
    return
end

print("Blocks scanned:", #data)

local coal = {}

for _, b in ipairs(data) do
    if b.name == "minecraft:coal_ore" or b.name == "minecraft:deepslate_coal_ore" then
        -- scanner block returns offsets
        table.insert(coal, {
            x = b.offset.x,
            y = b.offset.y,
            z = b.offset.z
        })
    end
end

print("Coal found:", #coal)

print("Broadcasting results...")
rednet.broadcast(coal, PROTOCOL)

print("DONE.")
