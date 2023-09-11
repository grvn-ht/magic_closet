import paho.mqtt.client as mqtt 
import time

broker_hostname = "151.80.152.245"
port = 1883 

def on_connect(client, userdata, flags, return_code):
    if return_code == 0:
        print("connected")
    else:
        print("could not connect, return code:", return_code)

client = mqtt.Client("Client1")
# client.username_pw_set(username="user_name", password="password") # uncomment if you use password auth
client.on_connect=on_connect

client.connect(broker_hostname, port)
client.loop_start()

topics = ["temp", "hum","ph","ec"]
closets = [1]
i=10
try:
    while i<=26:
        for clo in closets:
            for top in topics:
                mess = str(clo)+'|'+str(i)
                time.sleep(2)
                result = client.publish(top, mess)
                status = result[0]
                if status == 0:
                    print("Message "+ str(mess) + " is published to topic " + top)
                else:
                    print("Failed to send message to topic " + top)
                i += 1
        time.sleep(4)
finally:
    client.loop_stop()