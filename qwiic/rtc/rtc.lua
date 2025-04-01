-- Add sf: filesystem to package path
package.path = package.path .. ";sf:?.lua"

-- Built-in modules
system = require('system')
qwiic = require('qwiic')

-- RTC Lua modules (pick one)
--rtc = require('ds3231')
rtc = require('rv8803')

-- Output to syslog if available
if not system.syslog then
    system.syslog = print
end

-- Parse RFC-3339 date/time string
local function rfc_3339(str)
    local y, m, d, hh, mm, ss =
        string.match(str, "^(%d%d%d%d)%-(%d%d)%-(%d%d)[Tt](%d%d%.?%d*):(%d%d):(%d%d)()")
    if not y then
        return nil, "Invalid RFC-3339"
    end
    y  = tonumber(y, 10)
    m = tonumber(m, 10)
    d   = tonumber(d, 10)
    hh  = tonumber(hh, 10)
    mm   = tonumber(mm, 10)
    ss   = tonumber(ss, 10)
    return true, y, m, d, hh, mm, ss
end

-- Set RTC time
if #arg >= 1 then
  ok, y, m, d, hh, mm, ss = rfc_3339(arg[1])
  if not ok then
    print(y)
    return
  end
   ok = rtc.setTime(qwiic.i2c, y, m, d, hh, mm, ss)
   if not ok then
      print('rtc.setTime error')
      return
   end
end

-- Set internal time to RTC time
ok, y, m, d, hh, mm, ss = rtc.getTime(qwiic.i2c)
if ok then
    rfc3339 = string.format(
        '%04d-%02d-%02dT%02d:%02d:%02dZ',
        y, m, d, hh, mm, ss
    );
    ok = system.date(rfc3339)
    if ok then
        system.syslog('RTC: ' .. rfc3339)
    else
        system.syslog('RTC: system.date error')
    end
else
    system.syslog('RTC: rtc.getTime error')
end
