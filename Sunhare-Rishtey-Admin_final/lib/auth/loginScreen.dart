import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:sunhare_rishtey_new_admin/Screens/loadingScreen.dart';
import 'authService.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Text(
                    'Welcome To',
                    style: GoogleFonts.roboto(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: height * 0.015,
                ),
                Container(
                  child: Text(
                    'Admin',
                    style: GoogleFonts.roboto(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: HexColor('ff5252'),
                    ),
                  ),
                ),
                SizedBox(
                  height: height * .02,
                ),
                Center(
                  child: CircleAvatar(
                    backgroundImage: AssetImage('assets/shadiLogo.png'),
                    radius: 45,
                  ),
                ),
                SizedBox(
                  height: height * .03,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  height: height * 0.08,
                  width: MediaQuery.of(context).size.width * .68,
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  height: height * 0.08,
                  width: MediaQuery.of(context).size.width * .68,
                  child: TextField(
                    obscureText: true,
                    controller: passController,
                    decoration: InputDecoration(
                      hintText: 'Password',
                    ),
                  ),
                ),
                SizedBox(
                  height: height * 0.06,
                ),
                Container(
                  height: height * 0.05,
                  width: width * 0.5,
                  decoration: BoxDecoration(
                    color: HexColor('357f78'),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                      });
                      AuthService()
                          .signinWithEmail(
                              emailController.text, passController.text)
                          .then((value) {
                        if (value)
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => LoadingScreen(),
                            ),
                          );

                        setState(() {
                          isLoading = false;
                        });
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isLoading
                            ? SpinKitWave(
                                color: Colors.white,
                                size: 15,
                              )
                            : Icon(
                                Icons.login,
                                color: Colors.white,
                              ),
                        SizedBox(
                          width: width * 0.01,
                        ),
                        Text(
                          ' Sign in',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
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
