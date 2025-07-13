import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:social_media_app/helper/show_snack_bar.dart';
import 'package:social_media_app/services/prefrences_services.dart';
import 'package:social_media_app/utils/color_utility.dart';
import 'package:social_media_app/utils/image_utility.dart';
import 'package:social_media_app/widgets/custom_text_form_field.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool isSeen = false;

  Future<void> saveUserData(User user) async {
    await PreferencesServices.prefs?.setString('uid', user.uid);
    await PreferencesServices.prefs?.setString('email', user.email ?? '');
    await PreferencesServices.prefs?.setString('name', user.displayName ?? '');
    await PreferencesServices.prefs?.setString('photoUrl', user.photoURL ?? '');
  }

  Future signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final login = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      saveUserData(FirebaseAuth.instance.currentUser!);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print("Google Signin error $e");
      return null;
    }
  }

  Future<void> loginWithEmail({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await saveUserData(FirebaseAuth.instance.currentUser!);
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed.';

      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      }
      showSnackBar(context, message);
    } catch (e) {
      showSnackBar(context, 'An error occurred: $e');
    }
  }

  Future<void> signInWithFacebook(BuildContext context) async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;

        final OAuthCredential credential = FacebookAuthProvider.credential(
          accessToken.tokenString,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
        await saveUserData(FirebaseAuth.instance.currentUser!);
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // print('facebook account error : ${result.message}');
        showSnackBar(context, "Facebook login failed: ${result.message}");
      }
    } catch (e) {
      // print('facebook account error : $e');
      showSnackBar(context, "An error occurred: $e");
    }
  }

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  'Lets Sign You in',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28),
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Welcome Back, you have been missed',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextFormField(
                      label: 'Email',
                      hint: 'Enter Your Email',
                      controller: emailController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty ||
                            !value.contains('@')) {
                          return 'Email Field is Required and should contains @';
                        }
                        return null;
                      },
                    ),
                    CustomTextFormField(
                      label: 'Password',
                      hint: 'Enter Your Password',
                      controller: passwordController,
                      obscureText: !isSeen,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.visiblePassword,
                      suffixIcon: isSeen
                          ? IconButton(
                              onPressed: () {
                                setState(() {
                                  isSeen = !isSeen;
                                });
                              },
                              icon: Icon(Icons.remove_red_eye),
                            )
                          : IconButton(
                              onPressed: () {
                                setState(() {
                                  isSeen = !isSeen;
                                });
                              },
                              icon: Icon(Icons.visibility_off),
                            ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty ||
                            !value.contains(
                              RegExp(
                                r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[#$@!%*?&])[A-Za-z\d#$@!%*?&]{6,}$',
                              ),
                            )) {
                          return '''Password Field is Required at least 6 characters, should contain Capital Letters, Small Letters, Number and
                                     symbols like #%''';
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorUtility.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              showSnackBar(
                                context,
                                'You  Logged in Successfully! ${emailController.text}',
                              );

                              await loginWithEmail(
                                context: context,
                                email: emailController.text,
                                password: passwordController.text,
                              );

                              await Future.delayed(Duration(seconds: 1));
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              'Sign In',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const Divider(thickness: 1),
                    const Text("Or sign In with"),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        onPressed: signInWithGoogle,
                        icon: Image.asset(
                          ImageUtility.google,
                          height: 24,
                          width: 24,
                        ),
                        label: const Text(
                          "Google",
                          style: TextStyle(color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          signInWithFacebook(context);
                        },
                        icon: Image.asset(
                          ImageUtility.facebook,
                          height: 24,
                          width: 24,
                        ),
                        label: const Text("Facebook"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/sign-up');
                          },
                          child: Text(
                            "Sign Up",
                            style: TextStyle(color: ColorUtility.primary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
