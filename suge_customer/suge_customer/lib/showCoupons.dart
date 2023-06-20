import 'package:flutter/material.dart';
import 'package:suge_customer/util/common.dart';

class ShowCoupons extends StatefulWidget {
  final List<Map<dynamic, dynamic>> updateCouponList;

  const ShowCoupons(this.updateCouponList, {Key? key}) : super(key: key);

  @override
  _ShowCouponsState createState() => _ShowCouponsState();
}

class _ShowCouponsState extends State<ShowCoupons> {
  List<Map<dynamic, dynamic>> filteredCouponList = [];

  void searchStoreName(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCouponList = widget.updateCouponList;
      } else {
        filteredCouponList = widget.updateCouponList.where((coupon) {
          final storeName = coupon['storeName'].toString().toLowerCase();
          return storeName.contains(query.toLowerCase());
        }).toList();
        filteredCouponList.sort((a, b) => b['count'].compareTo(a['count']));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    filteredCouponList = widget.updateCouponList;
  }

  @override
  Widget build(BuildContext context) {
    // count에 내림차순 정렬
    return GestureDetector(
      onTap: () {
        // 키보드 포커스 해제
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: const Color(0xfff5f5f5),
        child: Column(
          children: [
            SizedBox(
              height: 120,
            ),
            Container(
              alignment: Alignment.center,
              child: Text(
                "쿠폰 리스트",
                style: textStyle20B,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: searchStoreName,
                decoration: InputDecoration(
                  filled: true,
                  // 배경 색상을 채우도록 설정
                  fillColor: Colors.white,
                  // 배경 색상 지정
                  hintText: "검색어를 입력하세요",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: customer), // 활성화되지 않은 텍스트 필드 테두리 색상 변경
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: Icon(
                    Icons.search,
                    color: customer,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                // 스크롤 가능한 실제 내용을 포함하는 위젯
                children: filteredCouponList.map((coupon) {
                  print(coupon);
                  return Container(
                    alignment: Alignment.center,
                    height: 100,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ) // 경계의 둥근 모서리 반지름 설정
                        ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          coupon['storeName'].toString(),
                          style: textStyle20Bold,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "${coupon['count']}개",
                          style: TextStyle(
                              fontFamily: 'GmarketMedium',
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: customer),
                        ),
                      ],
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
