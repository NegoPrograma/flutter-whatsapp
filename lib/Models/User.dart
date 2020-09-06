class User {
  String _name;
  String _email;
  String _password;

  User(this._name, this._email, this._password);
  User.loginConstructor(this._email, this._password);

  Map<String, dynamic> toMap() {
    return {"name": this.name, "email": this.email};
  }

  String get name => _name;

  set name(String value) => _name = value;

  String get email => _email;

  set email(String value) => _email = value;

  String get password => _password;

  set password(String value) => _password = value;
}
