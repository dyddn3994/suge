import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:suge_customer/navi.dart';
import 'package:suge_customer/util/common.dart';
import 'package:suge_customer/validator.dart';

import 'join.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController =
      TextEditingController(); //입력되는 값을 제어
  final TextEditingController _passwordController = TextEditingController();
  bool isPasswordVisible = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential?> _handleGoogleSignIn() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        final databaseRef = FirebaseDatabase.instance.ref();
        DatabaseEvent event = await databaseRef
            .child('user')
            .orderByChild('email')
            .equalTo(userCredential.user!.email)
            .once();
        if (event.snapshot.value == null) {
          FirebaseDatabase.instance.ref().child('user').push().set({
            'email': userCredential.user!.email,
            'name': '회원',
            'flag': 1,
          });
        }
        return userCredential;
      }
    } catch (error) {
      print('Google Sign-In Error: $error');
    }
    return null;
  }

  @override
  void initState() {
    //해당 클래스가 호출되었을떄
    super.initState();
  }

  @override
  void dispose() {
    // 해당 클래스가 사라질떄
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  _login() async {
    //키보드 숨기기
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).requestFocus(FocusNode());

      // Firebase 사용자 인증, 사용자 등록
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        final databaseRef = FirebaseDatabase.instance.ref();
        dynamic identify = false;

        DatabaseEvent event = await databaseRef
            .child('user')
            .orderByChild('email')
            .equalTo(_emailController.text)
            .once();
        Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          var flag = value['flag'];
          if (flag == 1) {
            identify = true;
          }
        });
        print("identify: $identify");
        if (!identify) {
          throw FirebaseAuthException(
            code: 'invalid-permission',
          );
        }
        saveLoginStatus(_emailController.text.toString(), true);

        Get.offAll(() => const Navi(), arguments: {
          'email': _emailController.text.toString(),
          'index': 1,
        });
      } on FirebaseAuthException catch (e) {
        print(e);
        String message = '';

        if (e.code == 'user-not-found') {
          message = '사용자가 존재하지 않습니다.';
        } else if (e.code == 'wrong-password') {
          message = '비밀번호를 확인해주세요';
        } else if (e.code == 'invalid-email') {
          message = '이메일를 확인하세요.';
        } else if (e.code == 'invalid-permission') {
          message = '이메일 혹은 비밀번호를 확인해주세요';
        } else {
          message = '이메일 혹은 비밀번호를 확인해주세요';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message, style: textStyle15),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Color(0xfff5f5f5),
        body: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              SizedBox(height: 50),
              Container(
                  height: 40,
                  margin: EdgeInsets.only(top: 10),
                  child: Image.asset(
                    'assets/suge_name_icon.png',
                    fit: BoxFit.contain,
                    color: customer,
                  )),
              SizedBox(height: 30),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  cursorColor: customer,
                  controller: _emailController,
                  keyboardType: TextInputType.text,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      // == null or isEmpty
                      return '아이디를 입력해주세요.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: "아이디",
                      labelStyle: textStyle20Grey,
                      floatingLabelStyle: textStyle20,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xffE0E0E0), width: 1),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: customer, width: 2))),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
                child: TextFormField(
                  obscureText: !isPasswordVisible,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  cursorColor: customer,
                  controller: _passwordController,
                  keyboardType: TextInputType.text,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      // == null or isEmpty
                      return '패스워드를 입력해주세요.';
                    }

                    return null;
                  },
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible =
                                !isPasswordVisible; // 패스워드 보이기 여부를 토글
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      hoverColor: customer,
                      labelText: "비밀번호",
                      labelStyle: textStyle20Grey,
                      floatingLabelStyle: textStyle20,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xffE0E0E0), width: 1),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: customer, width: 2))),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Material(
                        elevation: 5,
                        color: customer,
                        borderRadius: BorderRadius.circular(10),
                        child: MaterialButton(
                          onPressed: () {
                            _login();
                            print("login");
                          },
                          child: const Text(
                            "로그인",
                            style: textStyle20White,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  "아이디 찾기",
                  style: textStyle15GreyBold,
                ),
                Container(
                  width: 1,
                  height: 10,
                  color: Colors.grey,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                ),
                Text(
                  "비밀번호 찾기",
                  style: textStyle15GreyBold,
                ),
                Container(
                  width: 1,
                  height: 10,
                  color: Colors.grey,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => Join());
                  },
                  child: Text(
                    "회원 가입",
                    style: textStyle15GreyBold,
                  ),
                ),
              ]),
              SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 1,
                    width: 80,
                    color: Color(0xffE0E0E0),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "SNS 간편 로그인",
                      style: textStyle15Grey,
                    ),
                  ),
                  Container(
                    height: 1,
                    width: 80,
                    color: Color(0xffE0E0E0),
                  )
                ],
              ),
              SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _handleGoogleSignIn()
                          .then((UserCredential? userCredential) {
                        // 로그인 성공 후의 동작 처리
                        if (userCredential != null) {
                          saveLoginStatus(
                              userCredential.user!.email.toString(), true);
                          Get.offAll(() => const Navi(), arguments: {
                            'email': userCredential.user!.email,
                            'index': 1,
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text("로그인에 실패하였습니다.", style: textStyle15),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      });
                    },
                    icon: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Image.asset(
                        'assets/google.png', // SVG 이미지 파일의 경로
                        width: 24,
                        height: 24,
                      ),
                    ),
                    label: Text(
                      'Sign In With Google',
                      style: textStyle15BBlack,
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white // 배경색을 변경할 색상 지정
                        ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
