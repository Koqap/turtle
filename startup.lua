-- SmartMiner Turtle Startup Script
-- Automatically starts miner_v2 with saved home location

print("═══════════════════════════════════")
print("  SMARTMINER AUTO-STARTUP")
print("═══════════════════════════════════")

-- Check if home location exists
local HOME_FILE = "home_location.txt"

if fs.exists(HOME_FILE) then
    print("✓ Found saved home location")
    print("Starting miner in 3 seconds...")
    print("Press Ctrl+T to cancel")
    sleep(3)
    
    -- Run the miner
    shell.run("miner_v2")
else
    print("✗ No saved home location")
    print("Run 'miner_v2' manually to set up")
    print("")
    print("This will:")
    print("  1. Set home/chest location")
    print("  2. Save for future auto-starts")
    print("  3. Enable auto-restart on reboot")
end

print("")
print("Startup complete.")
