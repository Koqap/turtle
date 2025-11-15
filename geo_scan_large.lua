local RADIUS = 16   -- your limit
local TARGET = "minecraft:coal_ore"

print("Connecting to geo_scanner_1...")
local scanner = peripheral.wrap("geo_scanner_1")

if not scanner then
    error("GeoScanner not found at geo_scanner_1")
end

print("Scanning radius:", RADIUS)
local ok, data = scanner.scan(RADIUS)

if not ok then
    error("Scan failed: " .. tostring(data))
end

print("Scan complete! Filtering coal...")

local coal = {}

for _, block in ipairs(data) do
    if block.name == TARGET then
        table.insert(coal, block)
    end
end

print("Coal found:", #coal)

-- Save results
local file = fs.open("scan_results.txt", "w")
for i, b in ipairs(coal) do
    file.write(string.format(
        "%d. %s X:%d Y:%d Z:%d Dist=%.1f\n",
        i, b.name, b.x, b.y, b.z,
        math.sqrt(b.x*b.x + b.y*b.y + b.z*b.z)
    ))
end
file.close()

print("Saved to scan_results.txt")
