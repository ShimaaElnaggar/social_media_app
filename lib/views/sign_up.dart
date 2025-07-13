import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/helper/show_snack_bar.dart';
import 'package:social_media_app/services/prefrences_services.dart';
import 'package:social_media_app/utils/color_utility.dart';
import 'package:social_media_app/widgets/custom_text_form_field.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  late TextEditingController jobController;

  bool isSeen = false;
  Future<void> saveUserData(User user) async {
    await PreferencesServices.prefs?.setString('uid', user.uid);
    await PreferencesServices.prefs?.setString('email', user.email ?? '');
    await PreferencesServices.prefs?.setString('name', user.displayName ?? '');
    await PreferencesServices.prefs?.setString('photoUrl', user.photoURL ?? '');
  }

  Future<void> registerWithEmailPassword() async {
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
      await userCredential.user!.updateDisplayName(nameController.text.trim());

      await FirebaseAuth.instance.currentUser!.reload();

      final updatedUser = FirebaseAuth.instance.currentUser!;
      print("Display Name: ${updatedUser.displayName}");
      Navigator.pushReplacementNamed(context, '/home');
      await saveUserData(FirebaseAuth.instance.currentUser!);
    } on FirebaseAuthException catch (e) {
      String message = 'Something went wrong';
      if (e.code == 'weak-password') message = 'Password is too weak';
      if (e.code == 'email-already-in-use') message = 'Email already in use';
      // ignore: use_build_context_synchronously
      showSnackBar(context, message);
    }
  }

  @override
  void initState() {
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    jobController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    jobController.dispose();
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
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Lets Register Account',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28),
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Hello user, you have a greatful journey',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextFormField(
                      label: 'Name',
                      hint: 'Shimaa',
                      controller: nameController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty ||
                            value.trim().length < 6) {
                          return 'Name Field is Required at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    CustomTextFormField(
                      label: 'Email',
                      hint: 'shimaa@gmail.com',
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
                      hint: '12qw!Q',
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
                    CustomTextFormField(
                      label: 'Confirm Password',
                      hint: "******",
                      controller: confirmPasswordController,
                      textInputAction: TextInputAction.next,
                      obscureText: !isSeen,
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
                        if (value == null || value.trim().isEmpty) {
                          return "Confirm Password is required";
                        }
                        if (value != passwordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                    ),
                    CustomTextFormField(
                      label: 'Job',
                      hint: "Software Engineer",
                      controller: jobController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Job Field is Required';
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
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
                                'You  Created an Account Successfully! ${emailController.text}',
                              );

                              await Future.delayed(Duration(seconds: 1));
                              registerWithEmailPassword();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              'Sign Up',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account?'),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: Text(
                            "Sign In",
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
