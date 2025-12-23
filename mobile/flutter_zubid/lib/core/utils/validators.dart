class Validators {
  /// Validator for non-empty fields
  static String? notEmpty(String? value, {String message = 'This field cannot be empty'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  /// Validator for username fields
  static String? username(String? value) {
    final emptyCheck = notEmpty(value, message: 'Please enter a username');
    if (emptyCheck != null) return emptyCheck;

    if (value!.trim().length < 3) {
      return 'Username must be at least 3 characters long';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  /// Validator for username or email fields
  static String? usernameOrEmail(String? value) {
    final emptyCheck = notEmpty(value, message: 'Please enter your username or email');
    if (emptyCheck != null) return emptyCheck;
    return null;
  }

  /// Validator for email fields
  static String? email(String? value) {
    final emptyCheck = notEmpty(value, message: 'Please enter an email address');
    if (emptyCheck != null) return emptyCheck;

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validator for password fields
  static String? password(String? value, {int minLength = 8}) {
    final emptyCheck = notEmpty(value, message: 'Please enter a password');
    if (emptyCheck != null) return emptyCheck;

    if (value!.length < minLength) {
      return 'Password must be at least $minLength characters long';
    }
    // Uncomment the following lines to enforce more complex password requirements
    // if (!RegExp(r'^(?=.*[a-z])').hasMatch(value)) {
    //   return 'Password must contain at least one lowercase letter';
    // }
    // if (!RegExp(r'^(?=.*[A-Z])').hasMatch(value)) {
    //   return 'Password must contain at least one uppercase letter';
    // }
    // if (!RegExp(r'^(?=.*\d)').hasMatch(value)) {
    //   return 'Password must contain at least one number';
    // }
    return null;
  }

  /// Validator for confirming a password
  static String? confirmPassword(String? value, String password) {
    final emptyCheck = notEmpty(value, message: 'Please confirm your password');
    if (emptyCheck != null) return emptyCheck;

    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
