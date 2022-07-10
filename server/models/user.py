from werkzeug.security import generate_password_hash, check_password_hash
from kmplace import db

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), index=True, unique=True)
    username = db.Column(db.String(64), index=True, unique=False)
    fullname = db.Column(db.String(100), index=True, unique=False)
    login_counts = db.Column(db.Integer,default=0)
    password_hash = db.Column(db.String(300))
    activate = db.Column(db.Boolean,default=False)
    activation_token = db.Column(db.String(42))
    activation_date = db.Column(db.DateTime())
    token = db.Column(db.String(42))
    token_date = db.Column(db.DateTime())
    forgotten_password_token = db.Column(db.String(42))
    forgotten_password_date = db.Column(db.DateTime())

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

    def get_json_data(self):
        return {
            "email": self.email,
            "username": self.username,
            "fullname": self.fullname,
            "login_counts" : self.login_counts,
        }