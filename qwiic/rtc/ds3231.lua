local ds3231 =  {}

function decToBcd(val)
  return((math.floor(val/10)*16) + (val%10))
end

function bcdToDec(val)
  return((math.floor(val/16)*10) + (val%16))
end

function ds3231.getTime(i2c)
    local ok, rtc = i2c(0x68, {0}, 7)
    if ok and #rtc == 7 then
        second = bcdToDec(rtc[1])
        minute = bcdToDec(rtc[2])
        hour = bcdToDec(rtc[3])
        day = bcdToDec(rtc[5])
        month = bcdToDec(rtc[6])
        year = bcdToDec(rtc[7])+2000
    end
    return ok, year, month, day, hour, minute, second
end

function ds3231.setTime(i2c, y, m, d, hh, mm,ss)
  if (y < 2000) or (y > 2100) then
    return nil, 'Bad year'
  end
  local rtc = {
     0,
     decToBcd(ss),
     decToBcd(mm),
     decToBcd(hh),
     0,
     decToBcd(d),
     decToBcd(m),
     decToBcd(y-2000)
  }
  local ok, err = i2c(0x68, rtc)
  return ok, err
end

return ds3231
