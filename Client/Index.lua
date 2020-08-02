-- Spawns/Overrides with default NanosWorld's Sun
World.SpawnDefaultSun()

-- Sets the same time for everyone
local gmt_time = os.date("!*t", os.time())
World.SetTime((gmt_time.hour * 60 + gmt_time.min) % 24, gmt_time.sec)