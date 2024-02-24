from sqlalchemy import create_engine, MetaData, Table
from sqlalchemy.orm import sessionmaker
from datetime import datetime
import paho.mqtt.client as mqtt
import time
import threading
import datetime
from model import Info

infos_to_insert={}
# with open('mos_sub/sample_image.jpg', 'rb') as image_file:
#     image_data = image_file.read()
# info_to_insert['image']=image_data

# MQTT broker settings
broker_address =  "151.80.152.245" #"mosquitto"
port = 1883
topics = ["temp", "hum","ph","ec"]

def decode_message(message):
    try:
        print('message: '+ message)
        values = message.split("|")
        id_closet = values[0]
        final_value = float(values[1])
        return (id_closet,final_value)
    except:
        return (None,None)
# Callback when a message is received
def on_message(client, userdata, message):
    global infos_to_insert
    
    id_closet, value = decode_message(message.payload.decode("utf-8"))
    
    if id_closet is None:
        pass
    else:
        if id_closet not in infos_to_insert:
            #latest_info = Info.query.order_by(Info.created_at.desc()).first()
            #if latest_info != []:
            #    infos_to_insert[id_closet] = {'ec':latest_info.ec,'ph':latest_info.ph,'hum':latest_info.hum,'temp':latest_info.temp, 'image':latest_info.image}
            #else:
            infos_to_insert[id_closet] = {'ec':'ec','ph':'ph','hum':'hum','temp':'temp','image':'/tmp/images/*'}
        infos_to_insert[id_closet][message.topic]=value
        print(infos_to_insert[id_closet])

# Create an MQTT client
client = mqtt.Client()

# Set the message callback
client.on_message = on_message
client.username_pw_set("gur", "My super Password.") # uncomment if you use password auth

# Connect to the MQTT broker
client.connect(broker_address, port)

# Subscribe to the specified topics
for topic in topics:
    client.subscribe(topic)

# MQTT loop function (asynchronously)
def mqtt_loop():
    client.loop_forever()

def insert_infos_to_db(info_to_insert):
    # Database connection parameters
    db_url = "postgresql://gur:lemotdepassesecret!!-678@151.80.152.245:5432/fullcloset"
    engine = create_engine(db_url)
    metadata = MetaData()
    metadata.reflect(bind=engine)
    Session = sessionmaker(bind=engine)
    session = Session()

    Info = Table('info', metadata, autoload=True, autoload_with=engine)

    latest_info = session.query(Info).order_by(Info.c.created_at.desc()).first()

    if latest_info != []:
        if info_to_insert['ec'] == 'ec':
            info_to_insert['ec'] = latest_info.ec
        if info_to_insert['ph'] == 'ph':
            info_to_insert['ph'] = latest_info.ph
        if info_to_insert['hum'] == 'hum':
            info_to_insert['hum'] = latest_info.hum
        if info_to_insert['temp'] == 'temp':
            info_to_insert['temp'] = latest_info.temp
        if info_to_insert['image'] == '/tmp/images/*':
            info_to_insert['image'] = latest_info.image
    else:
        if info_to_insert['ec'] == 'ec':
            info_to_insert['ec'] = 0
        if info_to_insert['ph'] == 'ph':
            info_to_insert['ph'] = 0
        if info_to_insert['hum'] == 'hum':
            info_to_insert['hum'] = 0
        if info_to_insert['temp'] == 'temp':
            info_to_insert['temp'] = 0

    start_date = datetime.datetime(2023, 9, 11)
    info_to_insert['event_date']=start_date
    info_to_insert['created_at']=datetime.datetime.now()

    insert_statement = Info.insert().values(**info_to_insert)
    session.execute(insert_statement)
    session.commit()
    session.close()

# Your custom action to run every 5 minutes
def publish_infos_to_db():
    global infos_to_insert
    while True:
        # Access the global received_messages dictionary to retrieve MQTT messages
        try:
            for id_closet, to_insert in infos_to_insert.items():
                to_insert['closet_id']=id_closet
                insert_infos_to_db(to_insert)

            print(infos_to_insert)
            infos_to_insert={} 
            time.sleep(1920)  # Sleep for 5 minutes (300 seconds)
        except Exception as e:
            print(e)
            infos_to_insert={}
            time.sleep(60)  # Sleep for 5 minutes (300 seconds)
# Start the MQTT loop in a separate thread
mqtt_thread = threading.Thread(target=mqtt_loop)
mqtt_thread.start()

# Start the custom action timer in a separate thread
custom_action_thread = threading.Thread(target=publish_infos_to_db)
custom_action_thread.start()


# table_names = metadata.tables.keys()
# for table_name in table_names:
#     print(f"Table Name: {table_name}")

# select_query = select([User])
# result = session.execute(select_query)
# for row in result:
#     print(row)

# condition = and_(User.c.id.in_([4]))
# delete_statement = delete(User).where(condition)
# session.execute(delete_statement)
# session.commit()

# select_query = select([User])
# result = session.execute(select_query)
# for row in result:
#     print(row)

# Closet = Table('closet', metadata, autoload=True, autoload_with=engine)
# condition = and_(Closet.c.id.in_([2]))
# delete_statement = delete(Closet).where(condition)
# session.execute(delete_statement)
# session.commit()

# select_query = select([Closet])
# result = session.execute(select_query)
# for row in result:
#     print(row)

# condition = and_(Info.c.id.in_([51]))
# select_query = select([Info]).where(condition)
# result = session.execute(select_query)
# for row in result:
#     # Open the binary image file
#     image = Image.open(io.BytesIO(row.image))  # Replace with the path to your binary image file

#     # Display information about the image
#     print("Image Format:", image.format)
#     print("Image Mode:", image.mode)
#     print("Image Size:", image.size)

#     # Show or save the image
#     image.show()  # Display the image using the default viewer
#     # image.save('output_image.png')  # Save the image in a different format if needed
