--[[
-- Directory listing of the SD card
--]]
drive = require('drive')
sd_dir = drive.dir('sd:')
while true do
   local dir_entry = sd_dir()
   if dir_entry == nil then break end
   local yyyy, mm, dd = drive.yyyymmdd(dir_entry.fdate)
   local h, m, s = drive.hms(dir_entry.ftime)
   print(string.format(
     '%04d-%02d-%02d %02d:%02d:%02d %9s %s',
     yyyy, mm, dd, h, m, s,
     dir_entry.flags == 1 and '<DIR>' or string.format('%d', dir_entry.fsize),
     dir_entry.fname
   ))
end
