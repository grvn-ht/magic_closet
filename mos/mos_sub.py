import paho.mqtt.client as mqtt
import sqlite3

# MQTT broker settings
broker_address =  "151.80.152.245"
port = 1883
topics = ["topic1", "topic2"]

# Variables to store the values
value_topic1 = None
value_topic2 = None

# Callback when a message is received
def on_message(client, userdata, message):
    global value_topic1, value_topic2
    
    if message.topic == "topic1":
        value_topic1 = float(message.payload.decode())
    elif message.topic == "topic2":
        value_topic2 = float(message.payload.decode())

    # Check if both values are available
    if value_topic1 is not None and value_topic2 is not None:
        execute_sql_query(value_topic1, value_topic2)

# Create an MQTT client
client = mqtt.Client()

# Set the message callback
client.on_message = on_message

# Connect to the MQTT broker
client.connect(broker_address, port)

# Subscribe to the specified topics
for topic in topics:
    client.subscribe(topic)

# Start the MQTT client loop
client.loop_forever()

def execute_sql_query(value_topic1, value_topic2):
    # Connect to the SQLite database
    conn = sqlite3.connect('mqtt_data.db')
    cursor = conn.cursor()

    # Insert both values into the table
    cursor.execute("INSERT INTO mqtt_data (topic1_value, topic2_value) VALUES (?, ?)",
                    (value_topic1, value_topic2))

    # Commit the transaction and close the connection
    conn.commit()
    conn.close()
