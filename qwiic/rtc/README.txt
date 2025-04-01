To set time on RTC module:

1) Run rtc.lua with an RFC-3339 compliant date/time string

    lua rtc.lua 2025-03-03T17:18:08Z

To synchronize the system clock with the RTC at startup:

1) Edit rtc.lua to select your RTC module
2) Copy rtc.lua and your RTC module driver lua file to the sf: file system
3) Add 'lua sf:rtc.lua' to the 'sf:shell.cmd' startup file
