import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:suge_customer/selectReward.dart';
import 'package:suge_customer/util/common.dart';

class SelectStore extends StatefulWidget {
  final String userEmail;

  SelectStore(this.userEmail, {super.key});

  @override
  State<SelectStore> createState() => _SelectStoreState();
}

class _SelectStoreState extends State<SelectStore> {
  List<String> storeNames = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() {
    final databaseRef = FirebaseDatabase.instance.ref();
    databaseRef.child('store').onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? data =
            event.snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          List<dynamic> stores = data.values.toList();

          for (var store in stores) {
            String storeName = store['storeName'];
            setState(() {
              storeNames.add(storeName);
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfff5f5f5),
      child: Column(
        children: [
          SizedBox(
            height: 120,
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              "쿠폰을 사용할 매장을",
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
              // 스크롤 가능한 실제 내용을 포함하는 위젯
              children: storeNames.map((ele) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SelectReward(widget.userEmail),
                            settings: RouteSettings(arguments: ele)));
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    height: 100,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(20) // 경계의 둥근 모서리 반지름 설정
                        ),
                    child: Text("$ele", style: textStyle20B),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
