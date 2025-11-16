-- Simple GPS Host Startup

-- SET YOUR COORDINATES HERE

while true do
    shell.run("gps", "host")
    sleep(1)   -- If gps host stops, restart it
end
