// my_home_page.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:suge_customer/Login.dart';
import 'package:suge_customer/util/common.dart';

import 'navi.dart';

class Validator extends StatefulWidget {
  const Validator({Key? key}) : super(key: key);

  @override
  State<Validator> createState() => _ValidatorState();
}

class _ValidatorState extends State<Validator> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // _permission();
    _logout();
    _auth();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 제거해도 되는 부분이나, 추후 권한 설정과 관련된 포스팅 예정
  // _permission() async {
  //   Map<Permission, PermissionStatus> statuses = await [
  //     Permission.storage,
  //   ].request();
  //   //logger.i(statuses[Permission.storage]);
  // }

  _auth() {
    // 사용자 인증정보 확인. 딜레이를 두어 확인
    Future.delayed(const Duration(milliseconds: 300), () async {
      await getLoginStatus().then((value) => {
            if (!value['isLoggedIn'])
              {Get.off(() => const Login())}
            else
              {
                Get.off(() => Navi(), arguments: {
                  'email': value['email'].toString(),
                  'index': 1,
                })
              }
          });
    });
  }

  _logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
