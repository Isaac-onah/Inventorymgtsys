import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myinventory/models/user.dart';
import 'package:myinventory/shared/constant.dart';
import 'package:myinventory/shared/local/cash_helper.dart';
import 'package:myinventory/shared/toast_message.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;

class AuthController extends ChangeNotifier {
  GoogleSignIn _googleSignIn =
      GoogleSignIn(scopes: ['https://www.googleapis.com/auth/drive.appdata']);

//NOTE Sign with google --------------------
  String statusLoginMessage = "";
  ToastStatus toastLoginStatus = ToastStatus.Error;
  bool isloadingLogin = false;
  UserModel? _userModel = null;
  UserModel? get user => _userModel;
  UserCredential? _user = null;
  GoogleSignInAccount? _googleUser;
  ga.FileList? list;

  Future<void> signInWithGoogle() async {
    isloadingLogin = true;
    notifyListeners();
    try {
      _googleUser = await _googleSignIn.signIn();
      if (_googleUser == null) {
        isloadingLogin = false;
        showToast(message: "Sign-in cancelled", status: ToastStatus.Warning);
        notifyListeners();
        return;
      }

      final GoogleSignInAuthentication? googleAuth = await _googleUser?.authentication;

      if (googleAuth == null) {
        isloadingLogin = false;
        showToast(message: "Google authentication failed", status: ToastStatus.Error);
        notifyListeners();
        return;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final token = await user.getIdToken();
        _userModel = UserModel(
          displayName: user.displayName,
          email: user.email,
          photoURL: user.photoURL,
          token: token,
        );

        currentuser = _userModel;
        await CashHelper.saveUser(_userModel!);
        
        isloadingLogin = false;
        showToast(message: "Welcome, ${user.displayName}!", status: ToastStatus.Success);
        notifyListeners();
      } else {
        isloadingLogin = false;
        showToast(message: "Firebase user not found", status: ToastStatus.Error);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Sign in failed: $e');
      isloadingLogin = false;
      showToast(message: "Sign-in failed. Please check your connection.", status: ToastStatus.Error);
      notifyListeners();
    }
  }

// NOTE google Sign Out ----------------------

  String statusSignOutMessage = "";
  ToastStatus toastSignOutStatus = ToastStatus.Error;
  bool isloadingSignOut = false;
  Future<void> google_signOut() async {
    isloadingSignOut = true;
    notifyListeners();
    try {
      await _googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
      
      _userModel = null;
      currentuser = null;
      await CashHelper.removeDatabykey(key: "user");
      
      isloadingSignOut = false;
      showToast(message: "Logged out successfully", status: ToastStatus.Success);
      notifyListeners();
    } catch (error) {
      debugPrint('Sign out failed: $error');
      isloadingSignOut = false;
      showToast(message: "Sign-out failed", status: ToastStatus.Error);
      notifyListeners();
    }
  }

  Future<void> getUserData() async {
    UserModel? user = await CashHelper.getUser() ?? null;

    _userModel = user;
    notifyListeners();
  }

  String? getDrawerTitle() =>
      _userModel == null ? "SIGN IN" : _userModel?.displayName.toString();

  String? getDrawerSubTitle() => _userModel == null
      ? "Synchronization disabled"
      : "Synchronization enabled";


}

class GoogleHttpClient extends IOClient {
  Map<String, String> _headers;

  GoogleHttpClient(this._headers) : super();

  @override
  Future<IOStreamedResponse> send(http.BaseRequest request) =>
      super.send(request..headers.addAll(_headers));

  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) =>
      super.head(url, headers: headers!..addAll(_headers));
}
