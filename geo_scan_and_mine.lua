-- GEO MINE - Receives wireless scan results and mines coal

local PROTOCOL = "geo_scan_results"

-- Open modem (adjust side if needed, e.g., "left")
local modemSide = peripheral.find("modem")
if not modemSide then
    print("ERROR: No wireless modem on turtle!")
    return
end

rednet.open(peripheral.getName(modemSide))

print("Waiting for scan data...")
local id, coords = rednet.receive(PROTOCOL)

if not coords or type(coords) ~= "table" then
    print("ERROR: Invalid scan data received.")
    return
end

print("Received", #coords, "coal locations!")
sleep(1)

-- Helper: Dig forward safely
local function digForward()
    while turtle.detect() do turtle.dig() end
    while not turtle.forward() do turtle.attack() end
end

-- Helper: Turn to exact compass direction
function turtle.setFacing(dir)
    local directions = {
        north = 2,
        south = 0,
        west  = 3,
        east  = 1,
    }

    local facing = directions[dir]
    if not facing then return end

    while true do
        local x1, y1, z1 = gps.locate()
        sleep(0.1)
        turtle.turnRight()
        local x2, y2, z2 = gps.locate()
        sleep(0.1)

        if not x1 or not x2 then break end

        local dx = x2 - x1
        local dz = z2 - z1

        local current
        if dx == 1 then current = 1
        elseif dx == -1 then current = 3
        elseif dz == 1 then current = 0
        elseif dz == -1 then current = 2 end

        if current == facing then break end
    end
end

-- Move turtle to coordinate
local function gotoPos(tx, ty, tz)
    local x, y, z = gps.locate()
    if not x then
        print("ERROR: No GPS!")
        return false
    end

    -- Vertical movement
    while y < ty do turtle.up(); y = y + 1 end
    while y > ty do turtle.down(); y = y - 1 end

    -- X movement
    if tx > x then
        turtle.setFacing("east")
        for i = 1, tx - x do digForward() end
    elseif tx < x then
        turtle.setFacing("west")
        for i = 1, x - tx do digForward() end
    end

    -- Z movement
    if tz > z then
        turtle.setFacing("south")
        for i = 1, tz - z do digForward() end
    elseif tz < z then
        turtle.setFacing("north")
        for i = 1, z - tz do digForward() end
    end

    return true
end

-- MINING LOOP
for i, v in ipairs(coords) do
    print("Mining coal", i, "of", #coords)
    if gotoPos(v.x, v.y, v.z) then
        turtle.dig()
        turtle.digUp()
        turtle.digDown()
        print("✓ Mined coal at:", v.x, v.y, v.z)
    else
        print("✗ Failed to reach:", v.x, v.y, v.z)
    end
    sleep(0.2)
end

print("All coal mined!")
