class Validator {
  String? validateEmail(inputEmail) {
    if (inputEmail.isEmpty) return 'Email is not emty';
    String pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";

    RegExp regExp = RegExp(pattern);
    if (!regExp.hasMatch(inputEmail)) return 'Invalid Email address format';
    return null;
  } //validate pass

  String? validatePassword(password) {
    if (password.isEmpty) return 'Password is not empty';
    if (password.length <= 6) return 'Password must be more than 6 charater';
    if (password.length >= 32) return 'Password must be less than 32 charater';
    return null;
  }

  String? validateName(name) {
    if (name.isEmpty) return 'Name is not empty';
    if (name.length > 32) return 'Name must be less than 32 charater';
  }
}
