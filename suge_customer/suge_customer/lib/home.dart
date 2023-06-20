import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:suge_customer/showCoupons.dart';
import 'package:suge_customer/util/common.dart';

const Map<String, String> UNIT_ID = kReleaseMode
    ? {
        'android': 'ca-app-pub-5662901104700574/8792122339',
      }
    : {
        'android': 'ca-app-pub-3940256099942544/2247696110',
      };

class Home extends StatefulWidget {
  final String userEmail;

  const Home(this.userEmail, {Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var userName;
  final List<String> imageList = [
    'assets/banner1.png',
    'assets/banner2.png',
    'assets/banner3.png'
  ];
  List<Container> couponList = [];
  List<Map<dynamic, dynamic>> updateCouponList = [];
  late BannerAd banner;
  bool _isBannerAdReady = false;

  Future<void> fetchUserData(String email) async {
    DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
    List<Container> updatedCouponListContainers = [];
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
        List<Map<dynamic, dynamic>> fetchCouponList = [];
        couponList = [];
        updatedCouponListContainers = [];
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
                updatedCouponListContainers.add(Container(
                  color: Colors.white,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        coupon['storeName'].toString(),
                        style: textStyle20Bold,
                      ),
                      SizedBox(
                        width: 150,
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
                ));
              }
            }
          } else {
            print("coupon 비어있음");
          }
          setState(() {
            userName = value['name'];
            couponList = updatedCouponListContainers;
            updateCouponList = fetchCouponList;
          });
          // 데이터 출력 예시
        });
      } else {
        // 데이터가 존재하지 않는 경우
        print('해당 이름의 데이터를 찾을 수 없습니다.');
      }
    });
  }

  void loadAdMob() {
    banner = BannerAd(
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
      size: AdSize(width: 385, height: 150),
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      request: AdRequest(),
    )..load();
  }

  @override
  void initState() {
    // TODO: implement initState
    fetchUserData(widget.userEmail);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    loadAdMob();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // TODO: implement dispose@override
    banner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
            width: 120,
            margin: EdgeInsets.only(top: 10),
            child: Image.asset(
              'assets/suge_name_icon.png',
              fit: BoxFit.contain,
              color: customer,
            )),
      ),
      body: Container(
        color: const Color(0xfff5f5f5),
        child: ListView(
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20, horizontal: 30.0),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20)) // 경계의 둥근 모서리 반지름 설정
                      ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text.rich(TextSpan(children: <TextSpan>[
                        TextSpan(
                          text: userName ?? "",
                          style: TextStyle(
                            color: customer, // 파란색으로 설정
                            fontFamily: "GmarketBold",
                            fontSize: 30,
                          ),
                        ),
                        TextSpan(text: "님, \n오늘도 스게!", style: textStyle30),
                      ])),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius:
                          BorderRadius.circular(20) // 경계의 둥근 모서리 반지름 설정
                      ),
                  width:
                      _isBannerAdReady ? MediaQuery.of(context).size.width : 50,
                  height: _isBannerAdReady ? 150 : 50,
                  child: _isBannerAdReady
                      ? AdWidget(
                          ad: banner,
                        )
                      :
                      // : CarouselSlider(
                      //     options: CarouselOptions(
                      //       autoPlay: true,
                      //       autoPlayInterval: const Duration(seconds: 4),
                      //       viewportFraction: 1,
                      //       enlargeCenterPage: true,
                      //     ),
                      //     items: imageList.map((imageUrl) {
                      //       return Builder(
                      //         builder: (BuildContext context) {
                      //           return Container(
                      //               width: MediaQuery.of(context).size.width,
                      //               margin:
                      //                   EdgeInsets.symmetric(horizontal: 5.0),
                      //               decoration: BoxDecoration(
                      //                   color: Colors.grey,
                      //                   borderRadius: BorderRadius.circular(
                      //                       20) // 경계의 둥근 모서리 반지름 설정
                      //                   ),
                      //               child: ClipRRect(
                      //                 borderRadius: BorderRadius.circular(20.0),
                      //                 child: Image.asset(imageUrl,
                      //                     fit: BoxFit.fill),
                      //               ));
                      //         },
                      //       );
                      //     }).toList(),
                      //   ),
                      CircularProgressIndicator(),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(30.0, 30, 30, 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)) // 경계의 둥근 모서리 반지름 설정
                      ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("내 쿠폰함",
                              style: TextStyle(
                                  fontFamily: "GmarketBold", fontSize: 20)),
                          GestureDetector(
                            onTap: () {
                              // 쿠폰 리스트로 이동
                              print("hello");
                            },
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ShowCoupons(updateCouponList),
                                    ));
                              },
                              child: Text.rich(
                                TextSpan(children: <TextSpan>[
                                  TextSpan(
                                      text: "전체 ",
                                      style: TextStyle(
                                          fontFamily: "GmarketMedium",
                                          fontSize: 16,
                                          color: Colors.grey)),
                                  TextSpan(
                                      text: "+",
                                      style: TextStyle(
                                          fontFamily: "GmarketMedium",
                                          fontSize: 18,
                                          color: Colors.grey)),
                                ]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20))

                      // 경계의 둥근 모서리 반지름 설정
                      ),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2.6,
                  child: couponList.isNotEmpty
                      ? CarouselSlider(
                          options: CarouselOptions(
                            enableInfiniteScroll: false,
                            height: 150,
                            viewportFraction: 0.8,
                            enlargeCenterPage: true,
                          ),
                          items: couponList.map((coupon) {
                            return Builder(
                              builder: (BuildContext context) {
                                return PhysicalModel(
                                    color: Colors.transparent,
                                    elevation: 10.0,
                                    // elevation 값 설정
                                    shadowColor: Colors.black,
                                    borderRadius: BorderRadius.circular(10.0),
                                    clipBehavior: Clip.antiAlias,
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.circular(
                                                20) // 경계의 둥근 모서리 반지름 설정
                                            ),
                                        child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            child: coupon)));
                              },
                            );
                          }).toList(),
                        )
                      : Container(
                          alignment: Alignment.center,
                          child: const Text(
                            "보유 중인 쿠폰이 없습니다.",
                            style: textStyle20B,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
