import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  final googleSignIn = GoogleSignIn();
  final account = await googleSignIn.signIn();
  if (account != null) {
    final auth = await account.authentication;
    print(auth.accessToken);
    print(auth.idToken);
  }
}
