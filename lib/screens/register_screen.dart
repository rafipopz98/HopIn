import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hopin/global/global.dart';
import 'package:hopin/screens/main_page.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameTextEditingController = TextEditingController();
  final emailTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final addressTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  final confirmPasswordTextEditingController = TextEditingController();

  bool _isPassVisible = false;

  final _formKey = GlobalKey<FormState>();

  void _submit() async {
    //validate all form fields
    if (_formKey.currentState!.validate()) {
      await firebaseAuth
          .createUserWithEmailAndPassword(
              email: emailTextEditingController.text.trim(),
              password: passwordTextEditingController.text.trim())
          .then((auth) async {
        currentUser = auth.user;

        if (currentUser != null) {
          Map userMap = { 
            "id": currentUser!.uid,
            "name": nameTextEditingController.text.trim(),
            "email": emailTextEditingController.text.trim(),
            "address": addressTextEditingController.text.trim(),
            "phone": phoneTextEditingController.text.trim(),
          };
          DatabaseReference userRef =
              FirebaseDatabase.instance.ref().child("users");
          userRef.child(currentUser!.uid).set(userMap);
        }
        await Fluttertoast.showToast(msg: "Successfully Regestered!!");
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => MainScreen()));
      }).catchError((ErrorMessage) {
        Fluttertoast.showToast(msg: "Error Occured \n $ErrorMessage");
      });
    } else {
      Fluttertoast.showToast(msg: "All Fields should be Valid");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Column(
              children: [
                Image.asset(darkTheme
                    ? 'images/city-dark.jpg'
                    : 'images/city-light.jpg'),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Register',
                  style: TextStyle(
                    color: darkTheme ? Colors.white38 : Colors.black38,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 20, 15, 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextFormField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50)
                                ],
                                decoration: InputDecoration(
                                  hintText: "Name",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  filled: true,
                                  fillColor: darkTheme
                                      ? Colors.black45
                                      : Colors.grey.shade200,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide: BorderSide(
                                          width: 0, style: BorderStyle.none)),
                                  prefixIcon: Icon(Icons.person,
                                      color: darkTheme
                                          ? Colors.amber.shade400
                                          : Colors.grey),
                                ),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Name cannot be empty';
                                  }
                                  if (text.length < 2) {
                                    return 'Please enter Valid Name';
                                  }
                                  if (text.length > 49) {
                                    return 'Name Cannot be more than 49 characters';
                                  }
                                },
                                onChanged: (text) => setState(() {
                                  nameTextEditingController.text = text;
                                }),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(100)
                                ],
                                decoration: InputDecoration(
                                  hintText: "Email",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  filled: true,
                                  fillColor: darkTheme
                                      ? Colors.black45
                                      : Colors.grey.shade200,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide: BorderSide(
                                          width: 0, style: BorderStyle.none)),
                                  prefixIcon: Icon(Icons.person,
                                      color: darkTheme
                                          ? Colors.amber.shade400
                                          : Colors.grey),
                                ),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Email cannot be empty';
                                  }
                                  if (EmailValidator.validate(text) == true) {
                                    return null;
                                  }
                                  if (text.length < 2) {
                                    return 'Please enter Valid Email';
                                  }
                                  if (text.length > 99) {
                                    return 'Email Cannot be more than 99 characters';
                                  }
                                },
                                onChanged: (text) => setState(() {
                                  emailTextEditingController.text = text;
                                }),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              IntlPhoneField(
                                showCountryFlag: false,
                                dropdownIcon: Icon(Icons.arrow_drop_down,
                                    color: darkTheme
                                        ? Colors.amber.shade400
                                        : Colors.grey),
                                decoration: InputDecoration(
                                  hintText: "Phone",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  filled: true,
                                  fillColor: darkTheme
                                      ? Colors.black45
                                      : Colors.grey.shade200,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide: BorderSide(
                                          width: 0, style: BorderStyle.none)),
                                ),
                                initialCountryCode: "IN",
                                onChanged: (text) => setState(() {
                                  phoneTextEditingController.text =
                                      text.completeNumber;
                                }),
                              ),
                              TextFormField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(100)
                                ],
                                decoration: InputDecoration(
                                  hintText: "Address",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  filled: true,
                                  fillColor: darkTheme
                                      ? Colors.black45
                                      : Colors.grey.shade200,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide: BorderSide(
                                          width: 0, style: BorderStyle.none)),
                                  prefixIcon: Icon(Icons.person,
                                      color: darkTheme
                                          ? Colors.amber.shade400
                                          : Colors.grey),
                                ),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Address cannot be empty';
                                  }
                                  if (text.length < 2) {
                                    return 'Please enter Valid Address';
                                  }
                                  if (text.length > 49) {
                                    return 'Address Cannot be more than 99 characters';
                                  }
                                },
                                onChanged: (text) => setState(() {
                                  addressTextEditingController.text = text;
                                }),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                obscureText: !_isPassVisible,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50)
                                ],
                                decoration: InputDecoration(
                                    hintText: "Password",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    filled: true,
                                    fillColor: darkTheme
                                        ? Colors.black45
                                        : Colors.grey.shade200,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(40),
                                        borderSide: BorderSide(
                                            width: 0, style: BorderStyle.none)),
                                    prefixIcon: Icon(Icons.person,
                                        color: darkTheme
                                            ? Colors.amber.shade400
                                            : Colors.grey),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                          _isPassVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: darkTheme
                                              ? Colors.amber.shade400
                                              : Colors.grey),
                                      onPressed: () {
                                        setState(() {
                                          _isPassVisible = !_isPassVisible;
                                        });
                                      },
                                    )),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Password cannot be empty';
                                  }
                                  if (text.length < 6) {
                                    return 'Please enter Valid Password';
                                  }
                                  if (text.length > 49) {
                                    return 'Password Cannot be more than 49 characters';
                                  }
                                  return null;
                                },
                                onChanged: (text) => setState(() {
                                  passwordTextEditingController.text = text;
                                }),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                obscureText: !_isPassVisible,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50)
                                ],
                                decoration: InputDecoration(
                                    hintText: "Confirm Password",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    filled: true,
                                    fillColor: darkTheme
                                        ? Colors.black45
                                        : Colors.grey.shade200,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(40),
                                        borderSide: BorderSide(
                                            width: 0, style: BorderStyle.none)),
                                    prefixIcon: Icon(Icons.person,
                                        color: darkTheme
                                            ? Colors.amber.shade400
                                            : Colors.grey),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                          _isPassVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: darkTheme
                                              ? Colors.amber.shade400
                                              : Colors.grey),
                                      onPressed: () {
                                        setState(() {
                                          _isPassVisible = !_isPassVisible;
                                        });
                                      },
                                    )),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Confirm Password cannot be empty';
                                  }
                                  if (text !=
                                      passwordTextEditingController.text) {
                                    return 'Password do not match';
                                  }
                                  if (text.length < 6) {
                                    return 'Please enter Valid Password ';
                                  }
                                  if (text.length > 49) {
                                    return 'Password Cannot be more than 49 characters';
                                  }
                                  return null;
                                },
                                onChanged: (text) => setState(() {
                                  confirmPasswordTextEditingController.text =
                                      text;
                                }),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: darkTheme
                                          ? Colors.amber.shade400
                                          : Colors.blue,
                                      onPrimary: darkTheme
                                          ? Colors.black
                                          : Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(32),
                                      ),
                                      minimumSize: Size(double.infinity, 50)),
                                  onPressed: () {
                                    _submit();
                                  },
                                  child: Text(
                                    "Register",
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  )),
                              SizedBox(
                                height: 20,
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: darkTheme
                                        ? Colors.amber.shade400
                                        : Colors.blue,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Have an Account?",
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.grey),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: Text(
                                      "Sign In",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: darkTheme
                                              ? Colors.amber.shade400
                                              : Colors.blue),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ))
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
