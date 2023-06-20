import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:suge_customer/couponLog.dart';
import 'package:suge_customer/util/common.dart';

import 'Login.dart';
import 'modify.dart';

class MyPage extends StatefulWidget {
  final String userEmail;

  const MyPage(this.userEmail, {Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  var userName;

  Future<void> fetchUserData(String email) async {
    DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

    databaseRef
        .child('user')
        .orderByChild('email')
        .equalTo(email)
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        // 데이터가 존재하는 경우
        Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          // 각 데이터에 접근하고 원하는 작업을 수행합니다.
          setState(() {
            userName = value['name'];
          });
          String email = value['email'];
          // 데이터 출력 예시
          print("이메일: $email");
        });
      } else {
        // 데이터가 존재하지 않는 경우
        print('해당 이름의 데이터를 찾을 수 없습니다.');
      }
    });
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    saveLoginStatus("", false);
    print('로그아웃되었습니다.');
    Get.offAll(() => Login());
  }

  void showLogoutConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16.0),
              Text(
                "정말로 로그아웃 하시겠습니까?",
                style: TextStyle(fontSize: 15, fontFamily: "GmarketBold"),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // 모달 창 닫기
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customer, // 원하는 배경 색으로 설정
                    ),
                    child: Text("취소",
                        style: TextStyle(
                            fontSize: 15, fontFamily: "GmarketMedium")),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey, // 원하는 배경 색으로 설정
                    ),
                    onPressed: () {
                      Navigator.pop(context); // 모달 창 닫기
                      logout();
                      // 로그아웃 함수 호출
                    },
                    child: Text("로그아웃",
                        style: TextStyle(
                            fontSize: 15, fontFamily: "GmarketMedium")),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    fetchUserData(widget.userEmail);
    super.initState();
  }

  void dispose() {
    // 해당 클래스가 사라질떄

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfff5f5f5),
      child: Column(
        children: [
          Container(
            height: 180,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5), // 그림자 색상
                    spreadRadius: 2, // 그림자 퍼지는 범위
                    blurRadius: 5, // 그림자 흐리게 만드는 정도
                    offset: Offset(0, 3), // 그림자 위치 조정 (가로, 세로)
                  ),
                ],
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20))
                // 경계의 둥근 모서리 반지름 설정
                ),
            child: Padding(
              padding: const EdgeInsets.only(top: 64.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.account_circle,
                    size: 80,
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(TextSpan(children: <TextSpan>[
                        TextSpan(
                          text: userName != null && userName.length > 6
                              ? userName.substring(0, 6) + '...'
                              : userName ?? "",
                          style: textStyle20Bold,
                        ),
                        const TextSpan(text: " 님, 스게!", style: textStyle20),
                      ])),
                      const SizedBox(
                        height: 5,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (userName != "회원") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Modify(
                                        userName: userName,
                                        userEmail: widget.userEmail)));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("해당 계정은 이용 불가합니다.", style: textStyle15),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: SizedBox(
                          height: 30,
                          width: 150,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.settings_outlined,
                                  size: 22,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "회원정보 수정",
                                  style: TextStyle(
                                      fontFamily: 'GmarketMedium',
                                      fontSize: 15.0,
                                      color: Colors.grey),
                                ),
                                SizedBox(
                                  width: 30,
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    width: 100,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: ListView(
                // 스크롤 가능한 실제 내용을 포함하는 위젯
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CouponLog(userEmail: widget.userEmail)));
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      height: MediaQuery.of(context).size.height / 7,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(20) // 경계의 둥근 모서리 반지름 설정
                          ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("쿠폰 적립 및 사용내역", style: textStyle18),
                          SizedBox(
                            width: 35,
                          ),
                          Icon(Icons.arrow_forward_ios_rounded)
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    height: MediaQuery.of(context).size.height / 7,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(20) // 경계의 둥근 모서리 반지름 설정
                        ),
                    child: GestureDetector(
                      onTap: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("개인정보 수집 및 이용 약관", style: textStyle18),
                          SizedBox(),
                          Icon(Icons.arrow_forward_ios_rounded)
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    height: 100,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(20) // 경계의 둥근 모서리 반지름 설정
                        ),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 7,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("앱 버전", style: textStyle18),
                          SizedBox(
                            width: 110,
                          ),
                          Text("1.00", style: textStyle18)
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showLogoutConfirmation(context);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      height: MediaQuery.of(context).size.height / 7,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(20) // 경계의 둥근 모서리 반지름 설정
                          ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("로그아웃", style: textStyle18),
                          SizedBox(
                            width: 110,
                          ),
                          Icon(Icons.arrow_forward_ios_rounded)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
