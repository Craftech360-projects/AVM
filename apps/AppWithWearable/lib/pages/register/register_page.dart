// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class RegisterPage extends StatefulWidget {
//   @override
//   _RegisterPageState createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   bool _isPasswordVisible = false;

//   Future<void> _register() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         UserCredential userCredential =
//             await _auth.createUserWithEmailAndPassword(
//           email: _emailController.text,
//           password: _passwordController.text,
//         );
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Registration successful')),
//         );
//         Navigator.pop(context);
//       } on FirebaseAuthException catch (e) {
//         // Handle error
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(e.message ?? 'Registration failed')));
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
//     return Scaffold(
//       appBar: AppBar(title: Text('Register')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: <Widget>[
//               FlutterLogo(size: isSmallScreen ? 100 : 200),
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Text(
//                   "Welcome to AVMe!",
//                   textAlign: TextAlign.center,
//                   style: isSmallScreen
//                       ? Theme.of(context).textTheme.headlineLarge
//                       : Theme.of(context)
//                           .textTheme
//                           .headlineMedium
//                           ?.copyWith(color: Colors.black),
//                 ),
//               ),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   prefixIcon: Icon(Icons.email_outlined),
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return 'Please enter your email';
//                   }
//                   bool emailValid = RegExp(
//                           r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
//                       .hasMatch(value);
//                   if (!emailValid) {
//                     return 'Please enter a valid email';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 20),
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   prefixIcon: Icon(Icons.lock_outline_rounded),
//                   border: OutlineInputBorder(),
//                   suffixIcon: IconButton(
//                     icon: Icon(_isPasswordVisible
//                         ? Icons.visibility
//                         : Icons.visibility_off),
//                     onPressed: () {
//                       setState(() {
//                         _isPasswordVisible = !_isPasswordVisible;
//                       });
//                     },
//                   ),
//                 ),
//                 obscureText: !_isPasswordVisible,
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return 'Please enter your password';
//                   }
//                   if (value.length < 6) {
//                     return 'Password must be at least 6 characters';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 20),

//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     padding: EdgeInsets.all(10.0),
//                     // Background color of the button
//                   ),
//                   onPressed: _register, // Replace with your onPressed function
//                   child: Text(
//                     'Register',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),

//               // ElevatedButton(
//               //   onPressed: _register,
//               //   child: Text(
//               //     'Register',
//               //     style: TextStyle(
//               //         fontSize: 16,
//               //         color: Colors.white,
//               //         fontWeight: FontWeight.bold),
//               //   ),
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isPasswordVisible = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful')),
        );
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Registration failed')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      resizeToAvoidBottomInset:
          true, // This will resize the body when the keyboard appears
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                //FlutterLogo(size: isSmallScreen ? 100 : 200),
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
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    }
                    bool emailValid = RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(value);
                    if (!emailValid) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: EdgeInsets.all(10.0),
                      // Background color of the button
                    ),
                    onPressed:
                        _register, // Replace with your onPressed function
                    child: Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
