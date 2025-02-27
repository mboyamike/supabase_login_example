import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_login_example/helpers/validators.dart';

void main() {
  group('Validators', () {
    group('emailValidator', () {
      test('returns error message when email is null', () {
        expect(Validators.emailValidator(null), 'Please enter your email');
      });

      test('returns error message when email is empty', () {
        expect(Validators.emailValidator(''), 'Please enter your email');
      });

      test('returns error message when email format is invalid', () {
        expect(
            Validators.emailValidator('invalid'), 'Please enter a valid email');
        expect(Validators.emailValidator('invalid@'),
            'Please enter a valid email');
        expect(Validators.emailValidator('invalid@domain'),
            'Please enter a valid email');
        expect(Validators.emailValidator('@domain.com'),
            'Please enter a valid email');
      });

      test('returns null when email format is valid', () {
        expect(Validators.emailValidator('test@example.com'), null);
        expect(Validators.emailValidator('test.user@example.co.uk'), null);
        expect(Validators.emailValidator('test-user@domain.org'), null);
      });
    });

    group('passwordValidator', () {
      test('returns error message when password is null', () {
        expect(
            Validators.passwordValidator(null), 'Please enter your password');
      });

      test('returns error message when password is empty', () {
        expect(Validators.passwordValidator(''), 'Please enter your password');
      });

      test('returns error message when password is too short', () {
        expect(Validators.passwordValidator('12345'),
            'Please enter at least 6 letters');
      });

      test('returns null when password is valid', () {
        expect(Validators.passwordValidator('123456'), null);
        expect(Validators.passwordValidator('password123'), null);
        expect(Validators.passwordValidator('securePassword!'), null);
      });
    });
  });
}
