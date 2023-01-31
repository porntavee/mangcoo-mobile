import 'package:google_sign_in/google_sign_in.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

Future<GoogleSignInAccount> loginGoogle() async {
  return await _googleSignIn.signIn();
}

void logoutGoogle() {
  _googleSignIn.signOut();
}
