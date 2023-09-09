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

topic = "Test.586315"
topic1 = "Test.586316"

msg_count = 0

try:
    while msg_count < 50:
        time.sleep(1)
        msg_count += 1
        result = client.publish(topic, str(msg_count)+"|586315")
        result1 = client.publish(topic1, str(msg_count)+"|586316")

        status = result[0]
        status1 = result1[0]
        if status == 0:
            print("Message "+ str(msg_count) + " is published to topic " + topic)
            print("Messageeeeeeeeeeee "+ str(msg_count) + " is published to topic " + topic1)

        else:
            print("Failed to send message to topic " + topic)
finally:
    client.loop_stop()