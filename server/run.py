import os
from kmplace import app, socketio

if __name__ == '__main__':
    if os.environ.get('FLASK_FLASK_DEV', False):
        app.config['DEBUG'] = True
        use_reloader = True

    app.config['JSON_SORT_KEYS'] = False
    app.config['DEBUG'] = os.environ.get('FLASK_DEBUG', False)

    socketio.run(app, port=5000, host='0.0.0.0')

## . venv/scripts/activate
## flask run