import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// String userName = "김싸피";

// Color 정의
// const Color coffeeBrown = Color(0xff907f60);
// const Color coffeeBackground = Color(0xFFF0E3DB);
const Color customer = Color(0xff414FFD);

// TextStyle 정의
const TextStyle textBold50 =
    TextStyle(fontFamily: 'GmarketBold', fontSize: 50.0);
const TextStyle textBold30 =
    TextStyle(fontFamily: 'GmarketBold', fontSize: 30.0);
const TextStyle textBold50Customer =
    TextStyle(fontFamily: 'GmarketBold', fontSize: 50.0, color: customer);
const TextStyle textStyle10White =
    TextStyle(fontFamily: 'GmarketMedium', fontSize: 10.0, color: Colors.white);
const TextStyle textStyle10 =
    TextStyle(fontFamily: 'GmarketMedium', fontSize: 10.0);
const TextStyle textStyle15GreyBold =
    TextStyle(fontFamily: 'GmarketBold', fontSize: 15.0, color: Colors.grey);
const TextStyle textStyle15Grey = TextStyle(
    fontFamily: 'GmarketMedium', fontSize: 15.0, color: Color(0xffE0E0E0));
const TextStyle textStyle15 =
    TextStyle(fontFamily: 'GmarketMedium', fontSize: 15.0);
const TextStyle textStyle18 =
TextStyle(fontFamily: 'GmarketMedium', fontSize: 18.0);
const TextStyle textStyle15BBlack =
    TextStyle(fontFamily: 'GmarketBold', fontSize: 15.0, color: Colors.black);
const TextStyle textStyle20 =
    TextStyle(fontFamily: 'GmarketMedium', fontSize: 20.0);
const TextStyle textStyle20Bold = TextStyle(
    fontFamily: 'GmarketMedium', fontSize: 20.0, fontWeight: FontWeight.bold);
const TextStyle textStyle20Grey =
    TextStyle(fontFamily: 'GmarketMedium', fontSize: 20.0, color: Colors.grey);
const TextStyle textStyle20White =
    TextStyle(fontFamily: 'GmarketMedium', fontSize: 20.0, color: Colors.white);
const TextStyle textStyle20B = TextStyle(
    fontFamily: 'GmarketMedium', fontSize: 20.0, fontWeight: FontWeight.bold);
const TextStyle textStyle25 =
    TextStyle(fontFamily: 'GmarketMedium', fontSize: 25.0);
const TextStyle textStyle30 =
    TextStyle(fontFamily: 'GmarketMedium', fontSize: 30.0);
const TextStyle textStyle50 =
    TextStyle(fontFamily: 'GmarketMedium', fontSize: 50.0);
const TextStyle textStyleRed30 = TextStyle(
    fontFamily: 'GmarketMedium', fontSize: 30.0, color: Color(0xff9d0200));

const storeInfo = [
  {
    "storeName": "store1",
    "rewards": [
      {'reward': "reward1", 'count': 5},
      {'reward': "reward2", 'count': 10},
      {'reward': "reward3", 'count': 15},
    ],
    "ownerName": "정용우",
  },
  {
    "storeName": "store2",
    "rewards": [
      {'reward': "reward4", 'count': 5},
      {'reward': "reward5", 'count': 10},
      {'reward': "reward6", 'count': 15},
    ],
    "ownerName": "정용우",
  },
  {
    "storeName": "store3",
    "rewards": [
      {'reward': "reward7", 'count': 5},
      {'reward': "reward8", 'count': 10},
      {'reward': "reward9", 'count': 15},
    ],
    "ownerName": "정용우",
  }
];

const couponList = [
  {"storeName": "store1", 'count': 2},
  {"storeName": "store2", 'count': 3},
  {"storeName": "store3", 'count': 1},
];



Future<void> saveLoginStatus(String email, bool isLoggedIn) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', isLoggedIn);
  await prefs.setString('email', email);
}

// 로그인 상태 불러오기
Future<Map<String, dynamic>> getLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String? email = prefs.getString('email');
  return {
    'isLoggedIn': isLoggedIn,
    'email': email,
  };
}
