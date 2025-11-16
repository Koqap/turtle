-- SmartMiner Turtle Startup Script
-- Automatically starts miner_v2 with saved home location

print("═══════════════════════════════════")
print("  SMARTMINER AUTO-STARTUP")
print("═══════════════════════════════════")

-- Check if home location exists
local HOME_FILE = "home_location.txt"

if fs.exists(HOME_FILE) then
    print("✓ Found saved home location")
    print("✓ Auto-starting miner NOW...")
    print("(Ctrl+T to cancel)")
    print("")
    
    -- Run the miner immediately (will auto-load home and start mining)
    shell.run("miner_v2")
else
    print("✗ No saved home location found")
    print("")
    print("FIRST TIME SETUP:")
    print("  1. Place chest behind turtle")
    print("  2. Run: miner_v2")
    print("  3. Home will be saved automatically")
    print("  4. Next reboot = auto-start!")
    print("")
    print("To start setup now, type: miner_v2")
end

print("")
print("Startup complete.")
