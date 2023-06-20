import 'package:firebase_admin/firebase_admin.dart';
import 'package:firebase_auth/firebase_auth.dart';

// import 'package:firebase_admin/src/auth/user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:suge_customer/util/common.dart';

class Modify extends StatefulWidget {
  final dynamic userName;
  final dynamic userEmail;

  const Modify({required this.userName, required this.userEmail, Key? key})
      : super(key: key);

  @override
  State<Modify> createState() => _ModifyState();
}

class _ModifyState extends State<Modify> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController =
      TextEditingController(); //입력되는 값을 제어
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isPasswordCheckVisible = false;

  void initializeAdminSDK() {
    // Firebase Admin SDK 인증 정보 설정
    // 본인의 Firebase 프로젝트의 서비스 계정 키 파일 경로를 설정해야 합니다.
    FirebaseAdmin.instance.initializeApp(
      AppOptions(
        credential: FirebaseAdmin.instance.certFromPath(
            'config/uge-2ec7d-firebase-adminsdk-xwvmx-f010ea1ea3.json'),
      ),
    );
  }

  void changePassword(
      String email, String currentPassword, String newPassword) async {
    try {
      // 이메일과 현재 비밀번호로 사용자 인증
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: currentPassword,
      );

      // 비밀번호 변경
      await userCredential.user!.updatePassword(newPassword);

      // 비밀번호 변경 성공
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("변경 완료", style: textStyle15),
          backgroundColor: customer,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      // 인증 오류 또는 비밀번호 변경 실패
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("변경 실패", style: textStyle15),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
          child: ListView(
            shrinkWrap: true,
            children: [
              SizedBox(
                height: 50,
              ),
              Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text("회원정보 수정",
                        style: TextStyle(
                            fontFamily: 'GmarketMedium',
                            fontSize: 30,
                            color: customer)),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 8.0),
                    child: Container(
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        cursorColor: customer,
                        controller: _nameController,
                        keyboardType: TextInputType.text,
                        validator: (String? value) {
                          if (value!.isEmpty) {
                            // == null or isEmpty
                            return '이름을 입력해주세요.';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            hoverColor: customer,
                            labelText: widget.userName,
                            labelStyle: textStyle20Grey,
                            floatingLabelStyle: textStyle20,
                            filled: true,
                            fillColor: Color.fromARGB(255, 226, 225, 225),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xffE0E0E0), width: 1),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide:
                                    BorderSide(color: customer, width: 2))),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 8.0),
                    child: Container(
                      child: TextFormField(
                        enabled: false,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        cursorColor: customer,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            hoverColor: customer,
                            labelText: widget.userEmail,
                            labelStyle: textStyle20Grey,
                            floatingLabelStyle: textStyle20,
                            filled: true,
                            fillColor: Color.fromARGB(255, 226, 225, 225),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xffE0E0E0), width: 1),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide:
                                    BorderSide(color: customer, width: 2))),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 8.0),
                    child: Container(
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        obscureText: !isPasswordVisible,
                        cursorColor: customer,
                        controller: _passwordController,
                        keyboardType: TextInputType.text,
                        enableSuggestions: false,
                        autocorrect: false,
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
                            hoverColor: customer,
                            labelText: "현재 비밀번호 ",
                            labelStyle: textStyle20Grey,
                            floatingLabelStyle: textStyle20,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xffE0E0E0), width: 1),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide:
                                    BorderSide(color: customer, width: 2))),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 8.0),
                    child: Container(
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        obscureText: !isPasswordCheckVisible,
                        cursorColor: customer,
                        controller: _newPasswordController,
                        keyboardType: TextInputType.text,
                        enableSuggestions: false,
                        autocorrect: false,
                        validator: (String? value) {
                          if (value!.isEmpty) {
                            // == null or isEmpty
                            return '신규 비밀번호를 입력해주세요.';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(isPasswordCheckVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  isPasswordCheckVisible =
                                      !isPasswordCheckVisible; // 패스워드 보이기 여부를 토글
                                });
                              },
                            ),
                            hoverColor: customer,
                            labelText: "신규 비밀번호",
                            labelStyle: textStyle20Grey,
                            floatingLabelStyle: textStyle20,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xffE0E0E0), width: 1),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide:
                                    BorderSide(color: customer, width: 2))),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Material(
                        elevation: 5,
                        color: customer,
                        borderRadius: BorderRadius.circular(10),
                        child: MaterialButton(
                          onPressed: () async {
                            changePassword(
                                widget.userEmail,
                                _passwordController.text,
                                _newPasswordController.text);
                          },
                          child: const Text(
                            "변경",
                            style: textStyle20White,
                          ),
                        ),
                      ),
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
