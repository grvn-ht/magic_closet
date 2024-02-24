from flask import Flask,jsonify,request,Blueprint,make_response
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import create_access_token, current_user, jwt_required, JWTManager, \
                                get_jwt_identity, set_access_cookies, get_jwt, unset_jwt_cookies, \
                                get_csrf_token
from flask_cors import CORS,cross_origin
from model import setup_db, db_drop_and_create_all, User, Closet, Info
from datetime import timedelta,datetime,timezone
from functools import wraps
from data_creation import create_sample_data
import logging
from flask import send_file
from PIL import Image
import cv2
import os
from multiprocessing import Value
import numpy as np
import datetime

app = Flask(__name__)

# If true this will only allow the cookies that contain your JWTs to be sent
# over https. In production, this should always be set to True
app.config["JWT_COOKIE_SECURE"] = False
app.config["JWT_TOKEN_LOCATION"] = ["headers", "cookies"]
app.config["JWT_SECRET_KEY"] = "super-secret"  # Change this in your code!
app.config["JWT_ACCESS_TOKEN_EXPIRES"] = timedelta(hours=1)
app.config["JWT_COOKIE_CSRF_PROTECT"] = True

CORS(app, origins="*", supports_credentials=True)#origins="*", supports_credentials=True) #resources={r"/*": {"origins": "http://localhost:8080"}})#

jwt = JWTManager(app)
db = setup_db(app)
#db_drop_and_create_all(app)

views = Blueprint('views', __name__)

# Register a callback function that takes whatever object is passed in as the
# identity when creating JWTs and converts it to a JSON serializable format.
@jwt.user_identity_loader
def user_identity_lookup(user):
    return user.id

# Register a callback function that loads a user from your database whenever
# a protected route is accessed. This should return any python object on a
# successful lookup, or None if the lookup failed for any reason (for example
# if the user has been deleted from the database).
@jwt.user_lookup_loader
def user_lookup_callback(_jwt_header, jwt_data):
    identity = jwt_data["sub"]
    return User.query.filter_by(id=identity).one_or_none()

# Using an `after_request` callback, we refresh any token that is within 30
# minutes of expiring. Change the timedeltas to match the needs of your application.
#@jwt_required()
@app.after_request
#@custom_jwt_required(exclude_routes=["/register"])
def refresh_expiring_jwts(response):
    try:
        excluded_endpoints = ["/login", "/register", "/logout"]
        if request.path in excluded_endpoints:
            return response  # Skip the logic for excluded routes        
        exp_timestamp = get_jwt()["exp"]
        now = datetime.now(timezone.utc)
        target_timestamp = datetime.timestamp(now + timedelta(minutes=30))
        if target_timestamp > exp_timestamp:
            access_token = create_access_token(identity=get_jwt_identity())
            set_access_cookies(response, access_token)
        return response
    except (RuntimeError, KeyError):
        # Case where there is not a valid JWT. Just return the original response
        return response

@views.route("/login", methods=["POST"])
def login():
    try:
        content = request.form
        email = content.get("email")
        password = content.get("password")
        print(content)
        user = User.query.filter_by(email=email).one_or_none()
        if not user or not user.check_password(password):
            return jsonify("Wrong username or password"), 401
        access_token = create_access_token(identity=user)
        csrf = get_csrf_token(access_token)
        response = jsonify({
            "response":"success",
            "csrf":csrf,
            "acces":access_token})
        resp = app.make_response(response)
        set_access_cookies(resp, access_token)
        return resp
    except KeyError:
        return jsonify({'error': 'Missing or invalid data'}), 400

@views.route('/register', methods=["POST"])
def register():
    try:
        content = request.form
        print(content)
        mail = content.get("email")
        password = content.get("password")
        print(request.endpoint)
        print(request.path)

        # Check for valid email format using regular expression
        #if not re.match(r"[^@]+@[^@]+\.[^@]+", mail):
        #    return jsonify(["Invalid email format"])
        # Check for a robust password (at least 8 characters, with upper/lowercase and digits)
        #if not (len(password) >= 8 and any(c.isupper() for c in password) and any(c.islower() for c in password) and any(c.isdigit() for c in password)):
        #    return jsonify(["Weak password"])
        email = User.query.filter_by(email=mail).first()
        if email is None:
            register = User(email=mail, password=password)
            db.session.add(register)
            db.session.commit()
            access_token = create_access_token(identity=register)
            csrf = get_csrf_token(access_token)
            response = jsonify({
                "response":"Register success",
                "csrf":csrf,
                "acces":access_token})
            # Set the access token cookie in the response
            resp = app.make_response(response)
            set_access_cookies(resp, access_token)
            print("Response Headers:", resp.headers)
            return resp
        else:
            return jsonify({"response":"user alredy exist"})
    except KeyError:
        return jsonify({'response': 'Missing or invalid data'}), 400

@views.route('/logout', methods=['POST'])
@jwt_required()
def logout():
    response = jsonify({"response":"Logged out"})
    unset_jwt_cookies(response)
    return response

app.register_blueprint(views)

@app.route("/who_am_i", methods=["GET"])
@jwt_required()
def protected():
    # We can now access our sqlalchemy User object via `current_user`.
    return jsonify(
        id=current_user.id,
        email=current_user.email
    )

@app.route("/temperature", methods=["GET"])
#@jwt_required()
def get_temperature_data():
    temperature_data = Info.query.with_entities(Info.temp, Info.created_at).order_by(Info.created_at.desc()).limit(500).all()
    #Info.query.with_entities(Info.temp, Info.created_at).all()
    temperature_timestamps = [{'temperature': temp, 'timestamp': created_at.isoformat()} for temp, created_at in temperature_data]
    return jsonify(temperature_timestamps)

@app.route("/moisture", methods=["GET"])
#@jwt_required()
def get_moisture_data():
    moisture_data = Info.query.with_entities(Info.hum, Info.created_at).order_by(Info.created_at.desc()).limit(500).all()
    #Info.query.with_entities(Info.temp, Info.created_at).all()
    moisture_timestamps = [{'moisture': hum, 'timestamp': created_at.isoformat()} for hum, created_at in moisture_data]
    return jsonify(moisture_timestamps)

@app.route("/ph", methods=["GET"])
#@jwt_required()
def get_ph_data():
    ph_data = Info.query.with_entities(Info.ph, Info.created_at).order_by(Info.created_at.desc()).limit(500).all()
    #Info.query.with_entities(Info.temp, Info.created_at).all()
    ph_timestamps = [{'ph': ph, 'timestamp': created_at.isoformat()} for ph, created_at in ph_data]
    return jsonify(ph_timestamps)

@app.route("/ec", methods=["GET"])
#@jwt_required()
def get_ec_data():
    ec_data = Info.query.with_entities(Info.ec, Info.created_at).order_by(Info.created_at.desc()).limit(500).all()
    #Info.query.with_entities(Info.temp, Info.created_at).all()
    ec_timestamps = [{'ecc': ec, 'timestamp': created_at.isoformat()} for ec, created_at in ec_data]
    return jsonify(ec_timestamps)

@app.route("/image", methods=["GET"])
#@jwt_required()
def get_image_data():
    #image_data = Info.query.with_entities(Info.image, Info.created_at).order_by(Info.created_at.desc()).limit(1).all()
    #image_timestamps = [{'image': image, 'timestamp': created_at.isoformat()} for image, created_at in image_data]
    #return jsonify(image_timestamps[0])
    latest_info = Info.query.order_by(Info.created_at.desc()).first()
    return send_file(latest_info.image)

def is_black_dominant(image):
    img_array = np.array(image)
    avg_rgb = np.mean(img_array, axis=(0, 1))
    return np.all(avg_rgb < 50)

@app.route("/imagepost", methods=["POST"])
def upload():
    received = request
    img = None
    if received.files:
        print(received.files['imageFile'])
        file  = received.files['imageFile']
        nparr = np.fromstring(file.read(), np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        dat = datetime.datetime.now().strftime("%m.%d.%Y+%H:%M:%S")
        photo_path = "/tmp/images/"+dat+".jpg"
        cv2.imwrite(photo_path, img)

        # Récupérer la dernière ligne de la table
        latest_info = Info.query.order_by(Info.created_at.desc()).first()
        print(latest_info.image)
        if latest_info:
            # Mettre à jour la variable image de la dernière ligne
            latest_info.image = photo_path
            db.session.commit()

        gif=[]

        three_months_ago = datetime.datetime.now() - datetime.timedelta(days=90)
        images_last_3_months = Info.query.filter(Info.created_at >= three_months_ago).with_entities(Info.image).all()
        print(images_last_3_months)
        frames = [Image.open(im[0]) for im in images_last_3_months]
        frames = list(filter(lambda a: a != '/tmp/images/*', frames))
        # Charger les images et filtrer celles à dominance noire
        frames = [im for im in frames if not is_black_dominant(im)]

        if len(frames) > 100:
            step = len(frames) / 100  # Détermine le pas pour obtenir 100 images
            #print(step)
            sample_indices = [int(i * step) for i in range(100)]  # Indices pour l'échantillon
            #print(sample_indices)
            sample_images = [frames[i] for i in sample_indices]  # Crée l'échantillon
            #print(sample_images)
        else:
            print('else')
            sample_images = frames
            #print(sample_images)
        if sample_images != []:
            for im in sample_images:
                gif.append(im)
            print(datetime.datetime.now())
            gif[0].save('/tmp/gif.gif', save_all=True,optimize=False,append_images=gif[1:],loop=0)
        return "[SUCCESS] Image Received", 201
    else:
        return "[FAILED] Image Not Received", 204


@app.route("/gif", methods=["GET"])
#@jwt_required()
def get_gif_data():
    return send_file('/tmp/gif.gif')


def generateMetrics():
    ec_data = Info.query.filter(Info.closet_id == 1).order_by(Info.created_at.desc()).first()
    temp_hum_clem = Info.query.filter(Info.closet_id == 2).order_by(Info.created_at.desc()).first()
    #print(ec_data)
    ec = str(round(ec_data.ec, 2))
    ph = str(round(ec_data.ph, 2))
    temp = str(round(ec_data.temp, 2))
    hum = str(round(ec_data.hum, 2))
    if temp_hum_clem is None:
        temp_clem="0"
        hum_clem="0"
        ec_clem="0"
        ph_clem="0"
    else:
        temp_clem = str(round(temp_hum_clem.temp, 2))
        hum_clem = str(round(temp_hum_clem.hum, 2))
        ec_clem = str(round(temp_hum_clem.hum, 2))
        ph_clem = str(round(temp_hum_clem.hum, 2))

    return f'Temperature {temp} \nHumidity {hum} \nEc {ec} \nPh {ph}\nTempClem {temp_clem} \nHumClem {hum_clem}\nEcClem {ec_clem} \nPhClem {ph_clem}'

@app.route("/metrics", methods=["GET"])
def get_all_data():
    response = make_response(generateMetrics(), 200)
    response.mimetype = "text/plain"
    return response

@app.route("/testt", methods=["GET"])
#@jwt_required()
def get_ecc_data():
    ec_data = Info.query.with_entities(Info.ec, Info.created_at).order_by(Info.created_at.desc()).limit(500).all()
    #Info.query.with_entities(Info.temp, Info.created_at).all()
    ec_timestamps = [{'ecc': ec, 'timestamp': created_at.isoformat()} for ec, created_at in ec_data]
    return jsonify(ec_timestamps)

if __name__ != '__main__':
    print("diff de main")
    gunicorn_logger = logging.getLogger('gunicorn.error')
    app.logger.handlers = gunicorn_logger.handlers
    app.logger.setLevel(gunicorn_logger.level)
    #create_sample_data(db, User, Closet, Info,app)

if __name__ == "__main__":
    print("main")
    #create_sample_data(db, User, Closet, Info,app)
    app.run(debug=True, timeout=200)