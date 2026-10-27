class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Please enter your email address';
    if (!value.contains('@') || !value.contains('.'))
      return 'Please enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Please enter your password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    final pwdError = password(value);
    if (pwdError != null) return pwdError;
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter a username';
    if (value.trim().length < 3)
      return 'Username must be at least 3 characters';
    if (value.contains(' ')) return 'Username cannot contain spaces';
    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Please enter your full name';
    return null;
  }

  static String? notEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty)
      return '$fieldName cannot be empty';
    return null;
  }
}
