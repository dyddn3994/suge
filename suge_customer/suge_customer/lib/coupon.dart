import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:suge_customer/SelectStore.dart';
import 'package:suge_customer/util/common.dart';

import 'TimeTrackingSnackBar.dart';

class Coupon extends StatefulWidget {
  final String userEmail;

  const Coupon(this.userEmail, {Key? key}) : super(key: key);

  String get getEmail => userEmail;

  @override
  State<Coupon> createState() => _CouponState();
}

class _CouponState extends State<Coupon> {
  int pageIdx = 0;

  var userName;

  Future<void> fetchUserData(String email) async {
    DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
    databaseRef
        .child('user')
        .orderByChild('email')
        .equalTo(email)
        .onValue
        .listen((event) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (event.snapshot.value != null) {
        // 데이터가 존재하는 경우
        Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          // 각 데이터에 접근하고 원하는 작업을 수행합니다.
          userName = value['name'];
        });
      } else {
        // 데이터가 존재하지 않는 경우
        print('해당 이름의 데이터를 찾을 수 없습니다.');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUserData(widget.userEmail);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchUserData(widget.userEmail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: const Color(0xfff5f5f5),
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(TimeTrackingSnackBar(
                      duration: Duration(minutes: 3),
                      message: widget.userEmail,
                      onActionPressed: () {
                        // 스낵바 닫기 버튼을 눌렀을 때 수행할 동작
                      },
                    ));
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.qr_code_scanner_outlined,
                            size: 90,
                            color: customer,
                          ),
                        ),
                        Text(
                          "쿠폰 적립",
                          style: TextStyle(
                              fontFamily: 'GmarketBold', fontSize: 15.0),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 100,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SelectStore(widget.userEmail)));
                  },
                  child: Container(
                    child: Column(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.paid_outlined,
                            size: 80,
                            color: customer,
                          ),
                        ),
                        Text(
                          "쿠폰 사용",
                          style: TextStyle(
                              fontFamily: 'GmarketBold', fontSize: 15.0),
                        )
                      ],
                    ),
                  ),
                )
              ],
            )));
  }
}
