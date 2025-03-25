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
  // UserModel? get userModel => _userModel;
  UserCredential? _user = null;
  GoogleSignInAccount? _googleUser;
  ga.FileList? list;

  Future<void> signInWithGoogle() async {
    try {
      _googleUser = await _googleSignIn.signIn();
      if (_googleUser == null) {
        // Handle case when the user cancels the sign-in
        statusLoginMessage = "Sign-in cancelled.";
        toastLoginStatus = ToastStatus.Error;
        isloadingLogin = false;
        notifyListeners();
        return;
      }

      isloadingLogin = true;
      statusLoginMessage = "You have been successfully logged In";
      toastLoginStatus = ToastStatus.Success;
      notifyListeners();

      final GoogleSignInAuthentication? googleAuth = await _googleUser?.authentication;

      if (googleAuth == null) {
        statusLoginMessage = "Google sign-in failed. Please try again.";
        toastLoginStatus = ToastStatus.Error;
        isloadingLogin = false;
        notifyListeners();
        return;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      _user = await FirebaseAuth.instance.signInWithCredential(credential);

      if (_user?.user != null) {
        _user?.user?.getIdToken().then((token) {
          _userModel = UserModel(
              displayName: _user?.user!.displayName,
              email: _user?.user!.email,
              photoURL: _user?.user!.photoURL,
              token: token);

          currentuser = _userModel;
          CashHelper.saveUser(_userModel!);
          isloadingLogin = false;
          notifyListeners();
        });
      } else {
        statusLoginMessage = "User not found.";
        toastLoginStatus = ToastStatus.Error;
        isloadingLogin = false;
        notifyListeners();
      }
    } catch (e) {
      print('Sign in failed: $e');
      statusLoginMessage = "Login failed, check your network connection and try again.";
      toastLoginStatus = ToastStatus.Error;
      isloadingLogin = false;
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
    await _googleSignIn.signOut().then((value) {
      statusLoginMessage = "You have been successfully logged out";
      toastSignOutStatus = ToastStatus.Success;
      _userModel = null;
      currentuser = null;
      CashHelper.removeDatabykey(key: "user");
      isloadingSignOut = false;
      notifyListeners();
      // print(_user?.user?.displayName);
    }).catchError((error) {
      statusSignOutMessage =
          "Logged In failed, check your network connection and try again";
      toastSignOutStatus = ToastStatus.Error;
      isloadingSignOut = false;
      notifyListeners();
    });
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
