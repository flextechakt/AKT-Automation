rtos = require('rtos')
qwiic = require('qwiic')
QwiicGpio = require('QwiicGpio')

gpio = QwiicGpio.new(qwiic.i2c)

if not gpio:isConnected() then
   print("GPIO not connected")
   return
end

print('Syncing GPIO...')
gpio:getMode()
gpio:getGPIO()

print('Set all output...')
for i = 0, 7 do
   gpio:pinMode(i, QwiicGpio.GPIO_OUT)
end

print('Toggling pins...')
for i = 0, 7 do
   print("GPIO " .. i .. "...")
   gpio:digitalWrite(i, QwiicGpio.GPIO_HI)
   print(gpio:digitalRead(i) == QwiicGpio.GPIO_HI and "High" or "Low")
   rtos.delay(0.250)
   gpio:digitalWrite(i, QwiicGpio.GPIO_LO)
   print(gpio:digitalRead(i) == QwiicGpio.GPIO_HI and "High" or "Low")
   rtos.delay(0.250)
   gpio:digitalWrite(i, QwiicGpio.GPIO_HI)
   print(gpio:digitalRead(i) == QwiicGpio.GPIO_HI and "High" or "Low")
   rtos.delay(0.250)
   gpio:digitalWrite(i, QwiicGpio.GPIO_LO)
   print(gpio:digitalRead(i) == QwiicGpio.GPIO_HI and "High" or "Low")
   rtos.delay(0.250)
end
