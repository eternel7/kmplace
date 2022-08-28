import os
import sentry_sdk
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_socketio import SocketIO
from sentry_sdk.integrations.flask import FlaskIntegration
from flask_login import LoginManager

app = Flask(__name__,template_folder="templates")
socketio = SocketIO(app, cors_allowed_origins="*")

app.config['SECRET_KEY'] =  os.getenv("FLASK_SECRET_KEY", "myonlysecret!")

# mail configuration
app.config['MAIL_SERVER']= os.getenv("FLASK_SMTP_SERVER")
app.config['MAIL_PORT'] = os.getenv("FLASK_SMTP_PORT")
app.config['MAIL_USERNAME'] = os.getenv("FLASK_SMTP_MAIL")
app.config['MAIL_PASSWORD'] = os.getenv("FLASK_SMTP_PASSWORD")
app.config['MAIL_USE_TLS'] = os.getenv("FLASK_SMTP_USE_TLS","False").lower() in ('true','1','t')
app.config['MAIL_USE_SSL'] = os.getenv("FLASK_SMTP_USE_SSL","True").lower() in ('true','1','t')

# init sentry
sentry_dsn = os.getenv("FLASK_SENTRY_DSN")
if sentry_dsn:
    sentry_sdk.init(
        dsn=sentry_dsn,
        integrations=[FlaskIntegration()]
    )

# init db
app.config['SQLALCHEMY_DATABASE_URI'] =  'postgresql://' + os.getenv("FLASK_DATABASE_USER") +":"+ os.getenv("FLASK_DATABASE_PASSWORD") + "@" + os.getenv("FLASK_DATABASE_HOST") + ":5432/" + os.getenv("FLASK_DATABASE_NAME")
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)
migrate = Migrate(app, db)

#init login management
login_manager = LoginManager()
login_manager.init_app(app)

# load routes
import routes.rest
import routes.sockets

# load models
from models.user import User

@login_manager.user_loader
def load_user(user_id):
    print("load_user: " + user_id)
    return User.objects(id=user_id).first()

@login_manager.request_loader
def load_user_from_request(request):
    authorization = request.headers.get('Authorization')
    if authorization:
        token, email = authorization.split("|:|:|")
        if token and email:
            token = token.replace('Bearer ', '', 1)
            user = User.query.filter_by(email=email, token=token).first()
            if user and user.is_authenticated():
                return user

    # return None if method did not login the user
    return None

#init file upload
app.config['UPLOAD_FOLDER'] = os.getenv("FLASK_UPLOAD_FOLDER", "D:/kmplace/uploads")
app.config['MAX_CONTENT_LENGTH'] = 16 * 1000 * 1000 #16 Mb