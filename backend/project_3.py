#Hayden Pour
#Project3.  Backend python file
# gdocs: https://docs.google.com/document/d/1dCnL4XY8YFDFsfzBc0CUPte3JGJz8Bujy6fzbb6FwW4/edit?usp=sharing
# Demo video:https://youtu.be/YkHfbnXKjwc

import RPi.GPIO as GPIO
import os
from time import sleep
from datetime import datetime
from pubnub.pnconfiguration import PNConfiguration
from pubnub.pubnub import PubNub
from pubnub.callbacks import SubscribeCallback

os.system('modprobe w1-gpio')
os.system('modprobe w1-therm')

temp_sensor = '/sys/bus/w1/devices/28-3c01b556e84f/w1_slave'

pnconfig = PNConfiguration()

pnconfig.publish_key = 'pub-c-bfdbe3c0-b733-4969-93d2-57e89cd78fb2'
pnconfig.subscribe_key = 'sub-c-97a08f8e-2899-11eb-862a-82af91a3b28d'
pnconfig.uuid = 'Client-u1ddb'
pnconfig.ssl = True;
pubnub = PubNub(pnconfig)

channel = 'Channel-m957c9mdt'

GPIO.setwarnings(False)

servo = 11
light = 16

GPIO.setmode(GPIO.BOARD)
GPIO.setup(29,GPIO.IN, GPIO.PUD_UP)
GPIO.setup(servo,GPIO.OUT)
GPIO.setup(light,GPIO.OUT)
pwm = GPIO.PWM(servo, 50)
pwm.start(0)
speed = 0.5

class LED():
    def __init__(self):
       pass
    def LedOff():
        GPIO.output(light, False)
        print("Led Off")
    
    def LedOn():
        GPIO.output(light, True)
        print("Led On")

class FishFeeder():
    
    def __init__(self):
        pass

    def SetAngle(self, angle):
        duty = angle / 18 + 2
        GPIO.output(servo, True)
        pwm.ChangeDutyCycle(duty)
        sleep(0.5)
        GPIO.output(servo, False)
        pwm.ChangeDutyCycle(0)

    def FeedNow(self, duration, angle):
        FishFeeder().SetAngle(angle)
        sleep(duration)
        FishFeeder().SetAngle(0)
    
    def Cancel(self):
        pwm.stop()
        GPIO.cleanup()

def waitButton():
    #GPIO.wait_for_edge(29, GPIO.RISING)
    
    FishFeeder().FeedNow(0.5, 180)

def publish_callback(result, status):
    pass

class Temperature():
    def read_temp_raw():
        f = open(temp_sensor, 'r')
        lines = f.readlines()
        f.close
        return lines
    
    def read_temp():
        lines = Temperature.read_temp_raw()
        while lines[0].strip()[-3: ] != 'YES':
            sleep(0.2)
            lines = read_temp_raw()
        temp_result = lines[1].find('t=')

        if temp_result != -1:
            temp_string = lines[1].strip()[temp_result + 2: ]
            
            temp = float(temp_string) / 1000.0

            return temp

class Listener(SubscribeCallback):

    def message(self, pubnub, message):
        now = datetime.now()
        dt_string = now.strftime("%d/%m/%Y %H:%M:%S")
        output = "Feeded...at:  "+ dt_string
        appTemp = Temperature.read_temp()
        global speed
        if message.message["requester"] == 'PWM':
           speed = message.message["message"]
           print(speed)
        if message.message["requester"] == 'App':
           FishFeeder().FeedNow(speed, 180)
           print(speed)
           pubnub.publish().channel(channel).message({"requester": "pi", "message" : output}).pn_async(publish_callback)
           print('Button press was received...')
        elif message.message["requester"] == 'LedOff':
           LED.LedOff()
           pubnub.publish().channel(channel).message({"requester": "ledpi", "message" : 'LedOff'}).pn_async(publish_callback)
        elif message.message["requester"] == 'LedOn':
           LED.LedOn()
           pubnub.publish().channel(channel).message({"requester": "ledpi", "message" : 'LedOn'}).pn_async(publish_callback)
        elif message.message["requester"] == 'Apptemp': 
           pubnub.publish().channel(channel).message({"requester": "tempi", "message" : appTemp}).pn_async(publish_callback)
           print(appTemp)
        
print('Listening...')
pubnub.add_listener(Listener())
pubnub.subscribe().channels(channel).execute()


try:
    while True:
        print('Off')
        sleep(0.2)
       
    
except KeyboardInterrupt:
    GPIO.cleanup()
