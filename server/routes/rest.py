from flask import Flask, request, jsonify
from kmplace import app, db
from models.user import User
import datetime
import secrets


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

    db.session.add(u)
    db.session.commit()

    status = True
    message = "You have been registered"
    response = construct_response(status=status, message=message, data=u.get_json_data())
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