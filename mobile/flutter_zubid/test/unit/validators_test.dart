import 'package:flutter_test/flutter_test.dart';
import 'package:zubid_mobile/core/utils/validators.dart';

void main() {
  group('Email Validation', () {
    test('valid email returns null', () {
      expect(Validators.email('test@example.com'), isNull);
      expect(Validators.email('user.name@domain.co.uk'), isNull);
    });

    test('invalid email returns error message', () {
      expect(Validators.email('invalid'), isNotNull);
      expect(Validators.email('@nodomain.com'), isNotNull);
      expect(Validators.email(''), isNotNull);
    });

    test('null email returns error', () {
      expect(Validators.email(null), isNotNull);
    });
  });

  group('Password Validation', () {
    test('valid password returns null', () {
      expect(Validators.password('Password123!'), isNull);
      expect(Validators.password('SecurePass1@'), isNull);
    });

    test('weak password returns error', () {
      expect(Validators.password('123'), isNotNull);
      expect(Validators.password('short'), isNotNull);
      expect(Validators.password(''), isNotNull);
    });

    test('password missing lowercase returns error', () {
      expect(Validators.password('PASSWORD123!'), isNotNull);
    });

    test('password missing uppercase returns error', () {
      expect(Validators.password('password123!'), isNotNull);
    });

    test('password missing number returns error', () {
      expect(Validators.password('Password!!!'), isNotNull);
    });

    test('password missing special char returns error', () {
      expect(Validators.password('Password123'), isNotNull);
    });

    test('null password returns error', () {
      expect(Validators.password(null), isNotNull);
    });
  });

  group('Phone Validation', () {
    test('valid phone returns null', () {
      expect(Validators.phone('1234567890'), isNull);
      expect(Validators.phone('+1 234 567 8900'), isNull);
    });

    test('invalid phone returns error', () {
      expect(Validators.phone('123'), isNotNull);
      expect(Validators.phone(''), isNotNull);
    });
  });

  group('Username Validation', () {
    test('valid username returns null', () {
      expect(Validators.username('user123'), isNull);
      expect(Validators.username('john_doe'), isNull);
    });

    test('username too short returns error', () {
      expect(Validators.username('ab'), isNotNull);
    });

    test('empty username returns error', () {
      expect(Validators.username(''), isNotNull);
    });

    test('username with invalid chars returns error', () {
      expect(Validators.username('user@name'), isNotNull);
      expect(Validators.username('user name'), isNotNull);
    });
  });

  group('NotEmpty Validation', () {
    test('non-empty value returns null', () {
      expect(Validators.notEmpty('value'), isNull);
    });

    test('empty value returns error', () {
      expect(Validators.notEmpty(''), isNotNull);
      expect(Validators.notEmpty('   '), isNotNull);
      expect(Validators.notEmpty(null), isNotNull);
    });

    test('custom message is returned', () {
      final result = Validators.notEmpty('', message: 'Custom error');
      expect(result, equals('Custom error'));
    });
  });

  group('Confirm Password Validation', () {
    test('matching passwords return null', () {
      expect(
          Validators.confirmPassword('Password123!', 'Password123!'), isNull);
    });

    test('non-matching passwords return error', () {
      expect(Validators.confirmPassword('Password123!', 'Different456!'),
          isNotNull);
    });

    test('empty confirm password returns error', () {
      expect(Validators.confirmPassword('', 'Password123!'), isNotNull);
      expect(Validators.confirmPassword(null, 'Password123!'), isNotNull);
    });
  });

  group('Username or Email Validation', () {
    test('valid input returns null', () {
      expect(Validators.usernameOrEmail('username'), isNull);
      expect(Validators.usernameOrEmail('email@test.com'), isNull);
    });

    test('empty input returns error', () {
      expect(Validators.usernameOrEmail(''), isNotNull);
      expect(Validators.usernameOrEmail(null), isNotNull);
    });
  });
}
