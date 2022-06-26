import os
import sentry_sdk
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_socketio import SocketIO
from sentry_sdk.integrations.flask import FlaskIntegration

app = Flask(__name__)
socketio = SocketIO(app, cors_allowed_origins="*")

app.config['SECRET_KEY'] =  os.getenv("FLASK_SECRET_KEY", "myonlysecret!")

# init sentry
sentry_dsn = os.getenv("FLASK_SENTRY_DSN")
if sentry_dsn:
    sentry_sdk.init(
        dsn=sentry_dsn,
        integrations=[FlaskIntegration()]
    )

# init db
app.config['SQLALCHEMY_DATABASE_URI'] =  'postgresql://' + os.getenv("DATABASE_USER") +":"+ os.getenv("DATABASE_PASSWORD") + "@" + os.getenv("DATABASE_HOST") + ":5432/" + os.getenv("DATABASE_NAME")
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)
migrate = Migrate(app, db)

# load models
import models.user

# load routes
import routes.rest
import routes.sockets


if __name__ == '__main__':
    if os.environ.get('FLASK_FLASK_DEV', False):
        app.config['DEBUG'] = True
        use_reloader = True

    app.config['JSON_SORT_KEYS'] = False
    app.config['DEBUG'] = os.environ.get('FLASK_DEBUG', False)

    socketio.run(app, port=5000, host='0.0.0.0')