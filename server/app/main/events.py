from re import UNICODE
from flask import session
from flask_socketio import emit, join_room, leave_room
from .. import socketio

def getUser():
    user = session.get('name')
    if user is None:
        user = "someone"
    return user

def getRoom():
    user = session.get('name')
    if user is None:
        user = "room"
    return user


@socketio.on('connect')
def test_connect():
    emit('connected', {'data': 'Connected'})

@socketio.on('joined', namespace='/chat')
def joined(message):
    """Sent by clients when they enter a room.
    A status message is broadcast to all people in the room."""
    room = getRoom()
    user = getUser()
    join_room(room)
    print(user + ' is in room: ' + room)
    emit('status', {'user' : user, 'msg': user + ' has entered the room.'}, room=room)


@socketio.on('msg', namespace='/chat')
def text(message):
    """Sent by a client when the user entered a new message.
    The message is sent to all people in the room."""
    room = getRoom()
    user = getUser()
    msg = ''.join(chr(elt) for elt in message['msg'])
    emit('message', {'user' : user, 'msg': msg}, room=room)


@socketio.on('left', namespace='/chat')
def left(message):
    """Sent by clients when they leave a room.
    A status message is broadcast to all people in the room."""
    room = getRoom()
    user = getUser()
    leave_room(room)
    emit('status', {'user' : user, 'msg': user + ' has left the room.'}, room=room)

