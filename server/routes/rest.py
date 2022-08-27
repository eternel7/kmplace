from flask import Flask, request, abort, jsonify, render_template
from flask_mail import Mail, Message
from kmplace import app, db
from models.user import User
from flask_login import login_required, login_user, current_user, logout_user
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
    elif user.is_active is False:
        login_user(user)
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
        
        login_user(user)
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


@app.route('/api/logout', methods=['POST'])
@login_required
def logout():
    if current_user:
        current_user.token = "-invalid-"+secrets.token_urlsafe(16)+"-invalid-"
        current_user.token_date = datetime.datetime.now() - datetime.timedelta(days = 99)
        db.session.commit()
    logout_user()
    response = construct_response(status=True, message="logged out")
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
        user.is_active = True
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


@app.route('/api/forgottenpasswordcode', methods=['POST'])
def forgottenpasswordcodesend():

    content = request.form

    email = get_value_from_dict(content,"email")

    if not validate_string(email):
        status = False
        message = "Invalid data"
        response = construct_response(status=status, message=message)
        return jsonify(response)

    user = User.query.filter_by(email=email).first()
    if user is None:
        status = True
        message = "Message send"
        response = construct_response(status=status, message=message)
        return jsonify(response)
    else:
        forgotten_token = secrets.token_urlsafe(16)
        user.set_forgottenpasswordcode(forgotten_token)
        user.forgotten_password_date = datetime.datetime.now()
        db.session.commit()

        # Send forgotten password code by email
        msg = Message('Hello', sender = sendermail, recipients = [email])
        msg.body = "Need to reset your password? \nUse your secret code!\nforgotten_token\nIf you did not forget your password, you can ignore this email."
        msg.html = render_template('emails/forgottenpassword.html',forgotten_password_token=forgotten_token,title='Forgotten password code',email=email)
        msg.attach('forgot_password.png','image/png',open('./templates/assets/forgot_password.png', 'rb').read(), 'inline', headers=[['Content-ID','<forgotten_password_img>'],])
        msg.attach('logo_home.png','image/png',open('./templates/assets/logo_home.png', 'rb').read(), 'inline', headers=[['Content-ID','<logo_home_img>'],])
        mail.send(msg)

        status = True
        message = "Message send"
        response = construct_response(status=status, message=message)
        return jsonify(response)


@app.route('/api/forgottenpassword', methods=['POST'])
def forgottenpassword():

    content = request.form

    email = get_value_from_dict(content,'email')
    password = get_value_from_dict(content,'password')
    code = get_value_from_dict(content,'code')

    valid_input = validate_list_of_strings([email, password, code])
    if not valid_input:
        status = False
        message = "Invalid data"
        response = construct_response(status=status, message=message)
        return jsonify(response)

    user = User.query.filter_by(email=email).first()
    if user is None or not user.check_forgottenpasswordcode(code):
        status = False
        message = "Username or code incorrect"
        response = construct_response(status=status, message=message)
        return jsonify(response)
    elif user.forgotten_password_date < datetime.datetime.now() - datetime.timedelta(days=1) :
        status = False
        message = "Code too old"
        data = {"user" : user.get_json_data()}
        response = construct_response(status=status, message=message, data=data)
        return jsonify(response)
    else:
        user.forgotten_password_token = ""
        user.set_password(password)
        if not user.is_active :
            user.is_active = True
        db.session.commit()
            
        # Send update password email
        msg = Message('Hello', sender = sendermail, recipients = [email])
        msg.body = "Hello, your account on KMplace was just updated. \n If you suspect this is an unauthorized access, please Reset Your Password on KMplace." 
        msg.html = render_template('emails/updatedpassword.html',title='Password updated')
        msg.attach('password_updated.png','image/png',open('./templates/assets/password_updated.png', 'rb').read(), 'inline', headers=[['Content-ID','<password_updated_img>'],])
        msg.attach('logo_home.png','image/png',open('./templates/assets/logo_home.png', 'rb').read(), 'inline', headers=[['Content-ID','<logo_home_img>'],])
        mail.send(msg)
    
        # Send response
        status = True
        message = "Your password was successfully updated"
        response = construct_response(status=status, message=message, data=user.get_json_data())
        return jsonify(response)


@app.route('/api/useradditionalinfoupdate', methods=['POST'])
@login_required
def useradditionalinfoupdate():

    content = request.json

    email = get_value_from_dict(content,"email")

    if not validate_string(email):
        status = False
        message = "Invalid data"
        response = construct_response(status=status, message=message)
        return jsonify(response)

    user = User.query.filter_by(email=email).first()
    if user is None:
        status = False
        message = "Email incorrect"
        response = construct_response(status=status, message=message)
        return jsonify(response)
    else:
        username = get_value_from_dict(content,"username")
        fullname = get_value_from_dict(content,"fullname")
        image = get_value_from_dict(content,"image")
        user.username = username
        user.fullname = fullname
        user.image = image
        db.session.commit()
        

        status = True
        message = "Update done"
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