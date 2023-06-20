import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:suge_customer/util/common.dart';

import 'TimeTrackingSnackBar.dart';

class SelectReward extends StatefulWidget {
  final String userEmail;

  SelectReward(this.userEmail, {Key? key}) : super(key: key);

  @override
  State<SelectReward> createState() => _SelectRewardState();
}

class _SelectRewardState extends State<SelectReward> {
  late List<dynamic> rewardList = [];
  late int selectStoreCouponCount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchUserData(widget.userEmail);
    fetchData();
  }

  Future<void> fetchUserData(String email) async {
    final selStore = ModalRoute.of(context)?.settings.arguments;
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
          List<Map<dynamic, dynamic>> fetchCouponList = [];
          data.forEach((key, value) {
            // 각 데이터에 접근하고 원하는 작업을 수행합니다.
            Map<dynamic, dynamic>? coupons = value['coupons'];
            if (coupons != null) {
              coupons.forEach((key, value) {
                fetchCouponList.add(value as Map<dynamic, dynamic>);
              });
            }
            print('fetchCouponList: ${fetchCouponList.length}');
            if (fetchCouponList.isNotEmpty) {
              for (var coupon in fetchCouponList) {
                {
                  if (coupon['storeName'].toString() == selStore) {
                    setState(() {
                      selectStoreCouponCount = coupon['count'];
                    });
                  }
                }
              }
            } else {
              // 데이터가 존재하지 않는 경우
              print('데이터를 찾을 수 없습니다.');
            }
          });
        }
      });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fetchData() async {
    final selStore = ModalRoute.of(context)?.settings.arguments;
    final databaseRef = FirebaseDatabase.instance.ref();
    databaseRef.child('store').once().then((event) async {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? data =
            event.snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          List<dynamic> stores = data.values.toList();
          print("stores: $stores");
          for (var store in stores) {
            String storeName = store['storeName'];
            if (storeName == selStore) {
              setState(() {
                rewardList = store['rewards'];
                // rewardList가 업데이트되었음을 알리고 화면을 다시 그립니다.
              });
              break;
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xfff5f5f5),
        child: Column(
          children: [
            SizedBox(
              height: 120,
            ),
            Container(
              alignment: Alignment.center,
              child: Text(
                "원하는 리워드를",
                style: textStyle20B,
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Text(
                "선택해주세요",
                style: textStyle20B,
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Expanded(
              child: ListView(
                children: rewardList.map((reward) {
                  final rewardName = reward['reward'];
                  final count = reward['count'];

                  return GestureDetector(
                    onTap: () {
                      if (count <= selectStoreCouponCount) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(TimeTrackingSnackBar(
                          duration: Duration(minutes: 3),
                          message: '${widget.userEmail} $count',
                          onActionPressed: () {
                            // 스낵바 닫기 버튼을 눌렀을 때 수행할 동작
                          },
                        ));
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      height: 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: count <= selectStoreCouponCount
                            ? Colors.white
                            : Colors.grey,
                        // count와 selectStoreCouponCount 비교하여 색상 설정

                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("${rewardName}", style: textStyle20B),
                          SizedBox(
                            width: 200,
                          ),
                          Text("${count}개", style: textStyle20B),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
