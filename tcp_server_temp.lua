gpio.mode(5, gpio.OUTPUT)
gpio.write(5, 0)
port = 8888
local humidity = 0
local temperature = 0 
PIN = 0
DHT= require("dht_lib")
function readTemp()
    DHT.read11(PIN)
    temperature = DHT.getTemperature()
    humidity = DHT.getHumidity()
end

function open()
  print("Open connection...")
  srv=net.createServer(net.TCP) 
  srv:listen(port,function(conn) 
    conn:on("receive",function(conn,payload) 
        print(payload) 
        _, _, method, pin = string.find(payload, "([A-Z][0-9]+),([0-9]+)")
        if (method == 'D5') then
            gpio.write(5, tonumber(pin))
        end
        if (method == 'READ') then
            readTemp()
            if (humidity ~= nil) then
                conn:send('{ "Type": "TEMP", "SensorID":'.. node.chipid() .. ', "temperature": '..temperature..', "humidity": '..humidity..'}')           
            end
        end
    end) 
  end)
end

open()
