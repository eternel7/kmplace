from flask import Flask, request, jsonify, render_template
from flask_mail import Mail, Message
from kmplace import app, db
from models.user import User
import datetime
import secrets

sendermail = 'kmplace@unknow.app'

mail = Mail(app)

@app.route('/', methods=['GET'])
def home():
    return "KM Place"

@app.route('/debug-sentry' , methods=['GET'])
def trigger_error():
    division_by_zero = 1 / 0


@app.route('/user/<email>', methods=['GET'])
def profile(email):
    return f'{email}\'s profile'


@app.route('/api/login', methods=['POST'])
def login():

    content = request.form

    email = get_value_from_dict(content,"email")
    password = get_value_from_dict(content,"password")

    if not validate_string(email) or not validate_string(password):
        status = False
        message = "Invalid data"
        response = construct_response(status=status, message=message)
        return jsonify(response)

    user = User.query.filter_by(email=email).first()
    if user is None or not user.check_password(password):
        status = False
        message = "Username or password incorrect"
        response = construct_response(status=status, message=message)
        return jsonify(response)
    elif user.activate is False:
        status = False
        message = "Activation needed"
        data = {"user" : user.get_json_data()}
        response = construct_response(status=status, message=message, data=data)
        return jsonify(response)
    else:
        # Increase login count by 1
        user.login_counts = user.login_counts + 1
        user.token = secrets.token_urlsafe(16)
        user.token_date = datetime.datetime.now()
        db.session.commit()

        status = True
        message = "User logged in"
        data = {"token" : user.token,
                "user" : user.get_json_data()}
        response = construct_response(status=status, message=message, data=data)
        return jsonify(response)


@app.route('/api/register', methods=['POST'])
def register():
    
    content = request.form

    email = get_value_from_dict(content,'email')
    password = get_value_from_dict(content,'password')

    valid_input = validate_list_of_strings([email, password])
    if not valid_input:
        status = False
        message = "Invalid data"
        response = construct_response(status=status, message=message)
        return jsonify(response)

    if User.query.filter_by(email=email).count() == 1:
        status = False
        message = "Email already taken"
        response = construct_response(status=status, message=message)
        return jsonify(response)

    # Create new user
    u = User()
    u.email = email
    u.set_password(password)
    activation_token = secrets.token_urlsafe(16)[0:8]
    u.activation_token = activation_token
    u.activation_date = datetime.datetime.now()
    
    db.session.add(u)
    db.session.commit()

    # Send activation email
    msg = Message('Hello', sender = sendermail, recipients = [email])
    msg.body = "Hello, this is a registration message send from KMplace. \n Here is your activation code : "+activation_token 
    msg.html = render_template('emails/activation.html',activation_token=activation_token,title='Registration')
    msg.attach('activation.png','image/png',open('./templates/assets/activation.png', 'rb').read(), 'inline', headers=[['Content-ID','<activation_img>'],])
    msg.attach('logo_home.png','image/png',open('./templates/assets/logo_home.png', 'rb').read(), 'inline', headers=[['Content-ID','<logo_home_img>'],])
    mail.send(msg)
    
    # Send response
    status = True
    message = "You have been registered"
    response = construct_response(status=status, message=message, data=u.get_json_data())
    return jsonify(response)

@app.route('/api/activation', methods=['POST'])
def activation():

    content = request.form

    email = get_value_from_dict(content,"email")
    password = get_value_from_dict(content,"password")
    activationCode = get_value_from_dict(content,"activation_code")

    if not validate_string(email) or not validate_string(password) or not validate_string(activationCode):
        status = False
        message = "Invalid data"
        response = construct_response(status=status, message=message)
        return jsonify(response)

    user = User.query.filter_by(email=email).first()
    if user is None or not user.check_password(password):
        status = False
        message = "Username or password incorrect"
        response = construct_response(status=status, message=message)
        return jsonify(response)
    elif user.activation_token == activationCode:
        user.token = secrets.token_urlsafe(16)
        user.token_date = datetime.datetime.now()
        user.activate = True
        db.session.commit()

        status = True
        message = "User logged in"
        data = {"token" : user.token,
                "user" : user.get_json_data()}
        response = construct_response(status=status, message=message, data=data)
        return jsonify(response)
    else:
        status = False
        message = "Activation needed"
        data = {"user" : user.get_json_data()}
        response = construct_response(status=status, message=message, data=data)
        return jsonify(response)

@app.route('/api/activationsend', methods=['POST'])
def activationsend():

    content = request.form

    email = get_value_from_dict(content,"email")
    password = get_value_from_dict(content,"password")

    if not validate_string(email) or not validate_string(password):
        status = False
        message = "Invalid data"
        response = construct_response(status=status, message=message)
        return jsonify(response)

    user = User.query.filter_by(email=email).first()
    if user is None or not user.check_password(password):
        status = False
        message = "Username or password incorrect"
        response = construct_response(status=status, message=message)
        return jsonify(response)
    else:        
        activation_token = secrets.token_urlsafe(16)[0:8]
        user.activation_token = activation_token
        user.activation_date = datetime.datetime.now()
        db.session.commit()

        # Send activation email
        msg = Message('Hello', sender = sendermail, recipients = [email])
        msg.body = "Hello, this is a new activation code send from KMplace. \n Here is your new activation code : "+activation_token 
        msg.html = render_template('emails/activationnew.html',activation_token=activation_token,title='New activation code')
        msg.attach('activation.png','image/png',open('./templates/assets/activation.png', 'rb').read(), 'inline', headers=[['Content-ID','<activation_img>'],])
        msg.attach('logo_home.png','image/png',open('./templates/assets/logo_home.png', 'rb').read(), 'inline', headers=[['Content-ID','<logo_home_img>'],])
        mail.send(msg)

        status = True
        message = "Activation needed"
        data = {"user" : user.get_json_data()}
        response = construct_response(status=status, message=message, data=data)
        return jsonify(response)

# Helpers
def validate_string(input):
    if input is None or not input.strip():
        return False
    return True


def validate_list_of_strings(list):
    for i in list:
        if not validate_string(i):
            return False
    return True

def get_value_from_dict(dict,key):
    if key not in dict:
        return None
    return dict[key]

def construct_response(status, message, data=None):
    return {
        "status": status,
        "message": message,
        "data": data
    }