import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:suge_customer/util/common.dart';

class Join extends StatefulWidget {
  const Join({Key? key}) : super(key: key);

  @override
  State<Join> createState() => _JoinState();
}

class _JoinState extends State<Join> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController =
      TextEditingController(); //입력되는 값을 제어
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordCheckController =
      TextEditingController();

  @override
  void initState() {
    //해당 클래스가 호출되었을떄
    super.initState();
  }

  @override
  void dispose() {
    // 해당 클래스가 사라질떄
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordCheckController.dispose();
    super.dispose();
  }

  Future<bool> createUser(String email, String pw) async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).requestFocus(FocusNode());
    }
    if (pw != _passwordCheckController.text.toString()) {
      String message = '패스워드 확인이 패스워드와 다릅니다.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: textStyle15),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pw,
      );
    } on FirebaseAuthException catch (e) {
      print(e);
      String message = '';
      if (e.code == 'weak-password') {
        message = '패스워드가 너무 짧습니다.';
      } else if (e.code == 'email-already-in-use') {
        message = '사용자가 이미 존재합니다.';
      } else if (e.code == 'invalid-email') {
        message = '이메일 형식에 맞지 않습니다.';
      } else {
        message = e.code;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: textStyle15),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
    // authPersistence(); // 인증 영속
  }

  bool isPasswordVisible = false;
  bool isPasswordCheckVisible = false;

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
                      child: Text("회원님, \n환영합니다!",
                          style: TextStyle(
                              fontFamily: 'GmarketBold',
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
                          decoration: const InputDecoration(
                              hoverColor: customer,
                              labelText: "이름",
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
                          cursorColor: customer,
                          controller: _emailController,
                          keyboardType: TextInputType.text,
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              // == null or isEmpty
                              return '이메일을 입력해주세요.';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              hoverColor: customer,
                              labelText: "이메일",
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
                              labelText: "패스워드",
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
                          controller: _passwordCheckController,
                          keyboardType: TextInputType.text,
                          enableSuggestions: false,
                          autocorrect: false,
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              // == null or isEmpty
                              return '패스워드를 한 번 더 입력해주세요.';
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
                              labelText: "패스워드 확인",
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
                              await createUser(_emailController.text.toString(),
                                      _passwordController.text.toString())
                                  .then((value) => {
                                        if (value)
                                          {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text('회원가입에 성공했습니다.'),
                                                duration: Duration(seconds: 3),
                                                // 메시지가 표시될 시간 설정
                                                backgroundColor:
                                                    customer, // 배경 색상 설정
                                              ),
                                            ),
                                            FirebaseDatabase.instance
                                                .ref()
                                                .child('user')
                                                .push()
                                                .set({
                                              'email': _emailController.text,
                                              'name': _nameController.text,
                                              'flag': 1,
                                            }),
                                            Get.back(result: value)
                                          }
                                      });
                            },
                            child: const Text(
                              "회원가입",
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
      ),
    );
  }
}
