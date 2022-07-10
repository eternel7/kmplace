import os
from kmplace import app, socketio

if __name__ == '__main__':
    if os.environ.get('FLASK_FLASK_DEV', False):
        app.config['DEBUG'] = True
        use_reloader = True

    app.config['JSON_SORT_KEYS'] = False
    app.config['DEBUG'] = os.environ.get('FLASK_DEBUG', False)

    socketio.run(app, port=42080, host='0.0.0.0')

## DEV env : 
# . venv/scripts/activate
# flask run

## prod env :
#  cd /var/services/homes/admin/server 
# . venv/bin/activate
# export FLASK_APP=kmplace
# ...
# flask db migrate -m 'db_update_'.$EPOCHSECONDS
# flask db upgrade
# uwsgi --http 0.0.0.0:xxxx --master --wsgi-file run.py --callable app --threads 2

# TODO : https
