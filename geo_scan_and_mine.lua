------------------------------
--  WIRELESS COAL MINER     --
--  Uses GPS + wireless     --
--  Receives ore data       --
------------------------------

local PROTOCOL = "geo_scan_results"

-- Check modem
local modem = peripheral.find("modem", function(name, m) return m.isWireless() end)
if not modem then
    error("No wireless modem found! Attach a modem to the turtle.")
end
modem.open(PROTOCOL)

print("Waiting for scan data on protocol:", PROTOCOL)
print("Run the GEO SCAN on the computer...")

-- Wait for message
local event, side, sender, reply, message = os.pullEvent("modem_message")

if reply ~= PROTOCOL then
    error("Received wrong protocol: " .. tostring(reply))
end

local scanData = message

if type(scanData) ~= "table" then
    error("Invalid scan data received!")
end

print("Received", #scanData, "blocks from scanner.")

-- Filter for coal
local coal = {}
for _, b in ipairs(scanData) do
    if b.name == "minecraft:coal_ore" then
        table.insert(coal, b)
    end
end

print("Coal locations:", #coal)

-- GPS helper
local function gpsLoc()
    local x,y,z = gps.locate(2)
    if not x then error("GPS signal lost!") end
    return math.floor(x), math.floor(y), math.floor(z)
end

-- Movement
local function moveTo(tx, ty, tz)
    local x,y,z = gpsLoc()

    -- Y movement first (avoid obstacles)
    while y < ty do up(); y = y + 1 end
    while y > ty do down(); y = y - 1 end

    -- X movement
    local dx = tx - x
    if dx ~= 0 then
        face(dx > 0 and "east" or "west")
        for i=1, math.abs(dx) do forward() end
    end

    -- Z movement
    local dz = tz - z
    if dz ~= 0 then
        face(dz > 0 and "south" or "north")
        for i=1, math.abs(dz) do forward() end
    end
end

-- Basic dig wrappers
function forward()
    while not turtle.forward() do turtle.dig() sleep(0.1) end
end
function up()
    while not turtle.up() do turtle.digUp() sleep(0.1) end
end
function down()
    while not turtle.down() do turtle.digDown() sleep(0.1) end
end

-- Orientation helper
local dirs = {north=0, east=1, south=2, west=3}
local dirNames = {"north","east","south","west"}
local facing = 0  -- assume north on start

function face(target)
    local td = dirs[target]
    while facing ~= td do
        turtle.turnRight()
        facing = (facing + 1) % 4
    end
end

-- Remember start point
local startX, startY, startZ = gpsLoc()

-- Mine each coal block
for i, b in ipairs(coal) do
    print(string.format("Mining %d/%d: %s", i, #coal, b.name))
    moveTo(startX + b.x, startY + b.y, startZ + b.z)
    turtle.dig()
end

-- Return home
print("Returning to start...")
moveTo(startX, startY, startZ)

print("All coal mined!")
