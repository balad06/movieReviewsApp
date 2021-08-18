import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:moviereviewsapp/login/forgotPassword.dart';
import 'package:moviereviewsapp/screens/home.dart';
// import 'package:firebase_database/firebase_database.dart';

enum AuthMode { Signup, Login }

class LoginPage extends StatefulWidget {
  static const String id = '/LoginPage';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Future<String> signInWithGoogle() async {
  //   final GoogleSignIn googleSignIn = new GoogleSignIn();
  //   final GoogleSignInAccount? googleSignInAccount =
  //       await googleSignIn.signIn();
  //   final GoogleSignInAuthentication googleSignInAuthentication =
  //       await googleSignInAccount!.authentication;

  //   final AuthCredential credential = GoogleAuthProvider.credential(
  //     accessToken: googleSignInAuthentication.accessToken,
  //     idToken: googleSignInAuthentication.idToken,
  //   );

  //   final UserCredential authResult =
  //       await _auth.signInWithCredential(credential);
  //   final User? user = authResult.user;

  //   if (user != null) {
  //     assert(!user.isAnonymous);

  //     final User? currentUser = _auth.currentUser;
  //     assert(user.uid == currentUser!.uid);

  //     print('signInWithGoogle succeeded: $user');
  //     return '$user';
  //   }
  // }

  final _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  var _isLoading = false;
  final _passwordController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Widget _submitButton(BuildContext context) {
    return InkWell(
      hoverColor: Colors.purple[900],
      onTap: () {
        setState(() {});
        _submit(context);
      },
      child: Container(
        height: 50,
        width: MediaQuery.of(context).size.width * .45,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.amber,
        ),
        child: Text(
          _authMode == AuthMode.Login ? 'Login' : 'Register',
          style: TextStyle(
              fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _createAccountLabel() {
    if (_authMode == AuthMode.Login) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'New Here?',
              style: TextStyle(
                fontSize: 17,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: () {
                _switchAuthMode();
              },
              child: Text(
                'Register',
                style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    } else if (_authMode == AuthMode.Signup) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Have an Account?',
              style: TextStyle(
                fontSize: 17,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: () {
                _switchAuthMode();
              },
              child: Text(
                'Login here',
                style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  Future<void> _showErrorDialog(String message) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occured'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
              child: Text('close'),
              onPressed: () {
                Navigator.of(ctx).pop();
              }),
        ],
      ),
    );
  }

  void _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    _formKey.currentState!.save();
    setState(() {});
    UserCredential userCredential;
    try {
      setState(() {
        _isLoading = true;
      });
      if (_authMode == AuthMode.Login) {
        userCredential = await _auth.signInWithEmailAndPassword(
            email: _authData['email']!.trim(),
            password: _authData['password']!.trim());
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pushReplacementNamed(MyHomePage.id);
      } else {
        setState(() {
          _isLoading = true;
        });
        userCredential = await _auth.createUserWithEmailAndPassword(
            email: _authData['email']!.trim(),
            password: _authData['password']!.trim());
        print(_authData['email']!.trim());
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user?.uid)
            .set({
          'email': _authData['email'],
        });
        userCredential = await _auth.signInWithEmailAndPassword(
            email: _authData['email']!.trim(),
            password: _authData['password']!.trim());
        Navigator.of(context).pushReplacementNamed(MyHomePage.id);
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print(error);
      var errorMessage = 'Couldn\'t authenticate ';
      if (error.toString().contains('The email address is already in use')) {
        setState(() {
          errorMessage = 'email is already in use';
        });
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        setState(() {
          errorMessage = 'EMAIL_NOT_FOUND';
        });
      } else if (error.toString().contains('The password is invalid')) {
        setState(() {
          errorMessage = 'INVALID_PASSWORD';
        });
      }
      _showErrorDialog(errorMessage);
    }
  }

  Widget _formWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      key: ValueKey('email'),
                      decoration: InputDecoration(labelText: 'E-Mail'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty || !value.contains('@')) {
                          return 'Invalid email!';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) {
                        _authData['email'] = value!;
                        print(_authData['email']);
                      },
                    ),
                  ),
                  TextFormField(
                    key: ValueKey('pass'),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    controller: _passwordController,
                    validator: (value) {
                      if (value!.isEmpty || value.length < 7) {
                        return 'Password is too short!';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) {
                      _authData['password'] = value!;
                      print(_authData['password']);
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget checkboxorforgot() {
    if (_authMode == AuthMode.Login) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        alignment: Alignment.centerRight,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              ForgotPassword.id,
            );
          },
          child: Text(
            'Forgot Password ?',
            style: TextStyle(
                color: Colors.deepPurple,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        height: height,
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _authMode == AuthMode.Login
                        ? SizedBox(height: height * .125)
                        : SizedBox(height: height * .05),
                    Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        alignment: Alignment.center,
                        child: _authMode == AuthMode.Login
                            ? Row(
                                children: [
                                  Container(
                                    color: Colors.amber,
                                    height: 35,
                                    width: 8,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    'Login To Your ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,
                                        color: Colors.black),
                                  ),
                                  Text(
                                    'account',
                                    style: TextStyle(fontSize: 30),
                                  )
                                ],
                              )
                            : Row(
                                children: [
                                  Container(
                                    color: Colors.amber,
                                    height: 35,
                                    width: 8,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    'Register ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,
                                        color: Colors.black),
                                  ),
                                  Text(
                                    'Now',
                                    style: TextStyle(fontSize: 30),
                                  )
                                ],
                              )),
                    SizedBox(height: height * .015),
                    _formWidget(),
                    SizedBox(height: height * .0015),
                    checkboxorforgot(),
                    SizedBox(height: height * .04),
                    _isLoading
                        ? CircularProgressIndicator()
                        : _submitButton(context),
                    _createAccountLabel(),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Ink(
                        padding: EdgeInsets.all(10),
                        decoration: ShapeDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            shape: CircleBorder(),
                            shadows: [
                              new BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 6,
                                  offset: const Offset(0.0, 5.0))
                            ]),
                        child: IconButton(
                          icon: new Image.asset("assets/google_icon.png"),
                          padding: EdgeInsets.all(10),
                          onPressed: () async {
                            final GoogleSignIn googleSignIn =
                                new GoogleSignIn();
                            final GoogleSignInAccount? googleSignInAccount =
                                await googleSignIn.signIn();
                            final GoogleSignInAuthentication
                                googleSignInAuthentication =
                                await googleSignInAccount!.authentication;

                            final AuthCredential credential =
                                GoogleAuthProvider.credential(
                              accessToken:
                                  googleSignInAuthentication.accessToken,
                              idToken: googleSignInAuthentication.idToken,
                            );

                            final UserCredential authResult =
                                await _auth.signInWithCredential(credential);
                            final User? user = authResult.user;
                            if (authResult.additionalUserInfo!.isNewUser) {}
                            if (user != null) {
                              assert(!user.isAnonymous);
                              final User? currentUser = _auth.currentUser;
                              assert(user.uid == currentUser!.uid);
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(authResult.user?.uid)
                                  .set({
                                'email': user.email.toString(),
                              });
                              print('signInWithGoogle succeeded: $user');
                              Navigator.of(context)
                                  .pushReplacementNamed(MyHomePage.id);
                            }
                          },
                          iconSize: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
