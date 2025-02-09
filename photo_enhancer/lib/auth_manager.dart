import 'package:google_sign_in/google_sign_in.dart';

class AuthManager {
  // Sign-in method
  Future<String?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow

      await signOutFromGoogle();

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Authentication
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // You can now get the Google account details or authentication tokens
      print("User signed in: ${googleUser.displayName}");
      print("Google Account ID: ${googleUser.id}");
      print("Access Token: ${googleAuth.accessToken}");
      print("ID Token: ${googleAuth.idToken}");

      // You can now use the obtained tokens or account details as needed
      return googleUser.id;
    } catch (error) {
      print("Error signing in with Google: $error");
      return null;
    }
  }

// Sign-out method
  Future<void> signOutFromGoogle() async {
    await GoogleSignIn().signOut();
    print("User signed out");
  }
}
