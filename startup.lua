-- Simple GPS Host Startup

-- SET YOUR COORDINATES HERE
local x = 0
local y = 0
local z = 0

while true do
    shell.run("gps", "host", x, y, z)
    sleep(1)   -- If gps host stops, restart it
end
