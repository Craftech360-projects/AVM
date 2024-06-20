// // // import 'package:flutter/material.dart';
// // // import 'package:firebase_auth/firebase_auth.dart';
// // // import 'package:AVMe/pages/home/page.dart';
// // // import 'package:AVMe/backend/preferences.dart';

// // // class LoginPage extends StatefulWidget {
// // //   @override
// // //   _LoginPageState createState() => _LoginPageState();
// // // }

// // // class _LoginPageState extends State<LoginPage> {
// // //   final _formKey = GlobalKey<FormState>();
// // //   final _emailController = TextEditingController();
// // //   final _passwordController = TextEditingController();
// // //   final FirebaseAuth _auth = FirebaseAuth.instance;

// // //   Future<void> _login() async {
// // //     if (_formKey.currentState!.validate()) {
// // //       try {
// // //         UserCredential userCredential = await _auth.signInWithEmailAndPassword(
// // //           email: _emailController.text,
// // //           password: _passwordController.text,
// // //         );
// // //         SharedPreferencesUtil prefs = SharedPreferencesUtil();
// // //         prefs.isLoggedIn = true;
// // //         prefs.username = userCredential.user!.email!;
// // //         Navigator.pushReplacement(
// // //           context,
// // //           MaterialPageRoute(builder: (context) => HomePageWrapper()),
// // //         );
// // //       } on FirebaseAuthException catch (e) {
// // //         // Handle error
// // //         ScaffoldMessenger.of(context)
// // //             .showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
// // //       }
// // //     }
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: Text('Login')),
// // //       body: Padding(
// // //         padding: const EdgeInsets.all(16.0),
// // //         child: Form(
// // //           key: _formKey,
// // //           child: Column(
// // //             children: <Widget>[
// // //               TextFormField(
// // //                 controller: _emailController,
// // //                 decoration: InputDecoration(labelText: 'Email'),
// // //                 validator: (value) {
// // //                   if (value!.isEmpty) {
// // //                     return 'Please enter your email';
// // //                   }
// // //                   return null;
// // //                 },
// // //               ),
// // //               TextFormField(
// // //                 controller: _passwordController,
// // //                 decoration: InputDecoration(labelText: 'Password'),
// // //                 obscureText: true,
// // //                 validator: (value) {
// // //                   if (value!.isEmpty) {
// // //                     return 'Please enter your password';
// // //                   }
// // //                   return null;
// // //                 },
// // //               ),
// // //               SizedBox(height: 20),
// // //               ElevatedButton(
// // //                 onPressed: _login,
// // //                 child: Text('Login'),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // import 'package:AVMe/pages/register/register_page.dart';
// // import 'package:flutter/material.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:AVMe/pages/home/page.dart';
// // import 'package:AVMe/backend/preferences.dart';

// // class LoginPage extends StatefulWidget {
// //   @override
// //   _LoginPageState createState() => _LoginPageState();
// // }

// // class _LoginPageState extends State<LoginPage> {
// //   final _formKey = GlobalKey<FormState>();
// //   final _emailController = TextEditingController();
// //   final _passwordController = TextEditingController();
// //   final FirebaseAuth _auth = FirebaseAuth.instance;

// //   Future<void> _login() async {
// //     if (_formKey.currentState!.validate()) {
// //       try {
// //         UserCredential userCredential = await _auth.signInWithEmailAndPassword(
// //           email: _emailController.text,
// //           password: _passwordController.text,
// //         );
// //         SharedPreferencesUtil prefs = SharedPreferencesUtil();
// //         prefs.isLoggedIn = true;
// //         prefs.username = userCredential.user!.email!;
// //         Navigator.pushReplacement(
// //           context,
// //           MaterialPageRoute(builder: (context) => HomePageWrapper()),
// //         );
// //       } on FirebaseAuthException catch (e) {
// //         // Handle error
// //         ScaffoldMessenger.of(context)
// //             .showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
// //       }
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text('Login')),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Form(
// //           key: _formKey,
// //           child: Column(
// //             children: <Widget>[
// //               TextFormField(
// //                 controller: _emailController,
// //                 decoration: InputDecoration(labelText: 'Email'),
// //                 validator: (value) {
// //                   if (value!.isEmpty) {
// //                     return 'Please enter your email';
// //                   }
// //                   return null;
// //                 },
// //               ),
// //               TextFormField(
// //                 controller: _passwordController,
// //                 decoration: InputDecoration(labelText: 'Password'),
// //                 obscureText: true,
// //                 validator: (value) {
// //                   if (value!.isEmpty) {
// //                     return 'Please enter your password';
// //                   }
// //                   return null;
// //                 },
// //               ),
// //               SizedBox(height: 20),
// //               ElevatedButton(
// //                 onPressed: _login,
// //                 child: Text('Login'),
// //               ),
// //               TextButton(
// //                 onPressed: () {
// //                   Navigator.push(
// //                     context,
// //                     MaterialPageRoute(builder: (context) => RegisterPage()),
// //                   );
// //                 },
// //                 child: Text('Register'),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:AVMe/pages/register/register_page.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'package:AVMe/pages/home/page.dart';
// import 'package:AVMe/backend/preferences.dart';

// class LoginPage extends StatefulWidget {
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   bool _isPasswordVisible = false;
//   bool _rememberMe = false;

//   Future<void> _login() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//           email: _emailController.text,
//           password: _passwordController.text,
//         );
//         SharedPreferencesUtil prefs = SharedPreferencesUtil();
//         prefs.isLoggedIn = true;
//         prefs.username = userCredential.user!.email!;
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => HomePageWrapper()),
//         );
//       } on FirebaseAuthException catch (e) {
//         // Handle error
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

//     return Scaffold(
//       body: Center(
//         child: isSmallScreen
//             ? Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   _Logo(),
//                   _FormContent(
//                     formKey: _formKey,
//                     emailController: _emailController,
//                     passwordController: _passwordController,
//                     isPasswordVisible: _isPasswordVisible,
//                     rememberMe: _rememberMe,
//                     onPasswordVisibilityChanged: (value) {
//                       setState(() {
//                         _isPasswordVisible = value;
//                       });
//                     },
//                     onRememberMeChanged: (value) {
//                       setState(() {
//                         _rememberMe = value;
//                       });
//                     },
//                     onSubmit: _login,
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => RegisterPage()),
//                       );
//                     },
//                     child: Text('Register'),
//                   ),
//                 ],
//               )
//             : Container(
//                 padding: const EdgeInsets.all(32.0),
//                 constraints: const BoxConstraints(maxWidth: 800),
//                 child: Row(
//                   children: [
//                     Expanded(child: _Logo()),
//                     Expanded(
//                       child: Center(
//                         child: _FormContent(
//                           formKey: _formKey,
//                           emailController: _emailController,
//                           passwordController: _passwordController,
//                           isPasswordVisible: _isPasswordVisible,
//                           rememberMe: _rememberMe,
//                           onPasswordVisibilityChanged: (value) {
//                             setState(() {
//                               _isPasswordVisible = value;
//                             });
//                           },
//                           onRememberMeChanged: (value) {
//                             setState(() {
//                               _rememberMe = value;
//                             });
//                           },
//                           onSubmit: _login,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }
// }

// class _Logo extends StatelessWidget {
//   const _Logo({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         FlutterLogo(size: isSmallScreen ? 100 : 200),
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Text(
//             "Welcome to AVMe!",
//             textAlign: TextAlign.center,
//             style: isSmallScreen
//                 ? Theme.of(context).textTheme.headlineLarge
//                 : Theme.of(context)
//                     .textTheme
//                     .headlineMedium
//                     ?.copyWith(color: Colors.black),
//           ),
//         )
//       ],
//     );
//   }
// }

// class _FormContent extends StatelessWidget {
//   final GlobalKey<FormState> formKey;
//   final TextEditingController emailController;
//   final TextEditingController passwordController;
//   final bool isPasswordVisible;
//   final bool rememberMe;
//   final ValueChanged<bool> onPasswordVisibilityChanged;
//   final ValueChanged<bool> onRememberMeChanged;
//   final VoidCallback onSubmit;

//   const _FormContent({
//     Key? key,
//     required this.formKey,
//     required this.emailController,
//     required this.passwordController,
//     required this.isPasswordVisible,
//     required this.rememberMe,
//     required this.onPasswordVisibilityChanged,
//     required this.onRememberMeChanged,
//     required this.onSubmit,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       constraints: const BoxConstraints(maxWidth: 300),
//       child: Form(
//         key: formKey,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextFormField(
//               controller: emailController,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter some text';
//                 }

//                 bool emailValid = RegExp(
//                         r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
//                     .hasMatch(value);
//                 if (!emailValid) {
//                   return 'Please enter a valid email';
//                 }

//                 return null;
//               },
//               decoration: const InputDecoration(
//                 labelText: 'Email',
//                 hintText: 'Enter your email',
//                 prefixIcon: Icon(Icons.email_outlined),
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             _gap(),
//             TextFormField(
//               controller: passwordController,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter some text';
//                 }

//                 if (value.length < 6) {
//                   return 'Password must be at least 6 characters';
//                 }
//                 return null;
//               },
//               obscureText: !isPasswordVisible,
//               decoration: InputDecoration(
//                   labelText: 'Password',
//                   hintText: 'Enter your password',
//                   prefixIcon: const Icon(Icons.lock_outline_rounded),
//                   border: const OutlineInputBorder(),
//                   suffixIcon: IconButton(
//                     icon: Icon(isPasswordVisible
//                         ? Icons.visibility_off
//                         : Icons.visibility),
//                     onPressed: () {
//                       onPasswordVisibilityChanged(!isPasswordVisible);
//                     },
//                   )),
//             ),
//             _gap(),
//             CheckboxListTile(
//               value: rememberMe,
//               onChanged: (value) {
//                 if (value == null) return;
//                 onRememberMeChanged(value);
//               },
//               title: const Text('Remember me'),
//               controlAffinity: ListTileControlAffinity.leading,
//               dense: true,
//               contentPadding: const EdgeInsets.all(0),
//             ),
//             _gap(),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(4)),
//                 ),
//                 child: const Padding(
//                   padding: EdgeInsets.all(10.0),
//                   child: Text(
//                     'Sign in',
//                     style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 onPressed: onSubmit,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _gap() => const SizedBox(height: 16);
// }

import 'package:AVMe/pages/register/register_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:AVMe/pages/home/page.dart';
import 'package:AVMe/backend/preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  Future<void> _loadRememberMe() async {
    SharedPreferencesUtil prefs = SharedPreferencesUtil();
    _rememberMe = await prefs.getRememberMe();
    if (_rememberMe) {
      _emailController.text = await prefs.getEmail();
    }
    setState(() {});
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        SharedPreferencesUtil prefs = SharedPreferencesUtil();
        prefs.isLoggedIn = true;
        prefs.username = userCredential.user!.email!;
        if (_rememberMe) {
          await prefs.setEmail(_emailController.text);
        } else {
          await prefs.clearEmail();
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePageWrapper()),
        );
      } on FirebaseAuthException catch (e) {
        // Handle error
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Center(
        child: isSmallScreen
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Logo(),
                  _FormContent(
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    isPasswordVisible: _isPasswordVisible,
                    rememberMe: _rememberMe,
                    onPasswordVisibilityChanged: (value) {
                      setState(() {
                        _isPasswordVisible = value;
                      });
                    },
                    onRememberMeChanged: (value) {
                      setState(() {
                        _rememberMe = value;
                      });
                    },
                    onSubmit: _login,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white, // Set text color to white
                    ),
                    child: Text('Register'),
                  ),
                ],
              )
            : Container(
                padding: const EdgeInsets.all(32.0),
                constraints: const BoxConstraints(maxWidth: 800),
                child: Row(
                  children: [
                    Expanded(child: _Logo()),
                    Expanded(
                      child: Center(
                        child: _FormContent(
                          formKey: _formKey,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          isPasswordVisible: _isPasswordVisible,
                          rememberMe: _rememberMe,
                          onPasswordVisibilityChanged: (value) {
                            setState(() {
                              _isPasswordVisible = value;
                            });
                          },
                          onRememberMeChanged: (value) {
                            setState(() {
                              _rememberMe = value;
                            });
                          },
                          onSubmit: _login,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // FlutterLogo(size: isSmallScreen ? 100 : 200),
        Image.asset(
          'assets/images/herologo.png',
          width: isSmallScreen ? 100 : 200,
          height: isSmallScreen ? 100 : 200,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Welcome to AVMe!",
            textAlign: TextAlign.center,
            style: isSmallScreen
                ? Theme.of(context).textTheme.headlineLarge
                : Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: Colors.black),
          ),
        )
      ],
    );
  }
}

class _FormContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isPasswordVisible;
  final bool rememberMe;
  final ValueChanged<bool> onPasswordVisibilityChanged;
  final ValueChanged<bool> onRememberMeChanged;
  final VoidCallback onSubmit;

  const _FormContent({
    Key? key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isPasswordVisible,
    required this.rememberMe,
    required this.onPasswordVisibilityChanged,
    required this.onRememberMeChanged,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }

                bool emailValid = RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(value);
                if (!emailValid) {
                  return 'Please enter a valid email';
                }

                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            _gap(),
            TextFormField(
              controller: passwordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }

                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      onPasswordVisibilityChanged(!isPasswordVisible);
                    },
                  )),
            ),
            _gap(),
            // CheckboxListTile(
            //   value: rememberMe,
            //   onChanged: (value) {
            //     if (value == null) return;
            //     onRememberMeChanged(value);
            //   },
            //   title: const Text('Remember me'),
            //   controlAffinity: ListTileControlAffinity.leading,
            //   dense: true,
            //   contentPadding: const EdgeInsets.all(0),
            // ),
            // _gap(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Sign in',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                onPressed: onSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);
}
