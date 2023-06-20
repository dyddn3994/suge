import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:suge_customer/home.dart';
import 'package:suge_customer/util/common.dart';

import 'coupon.dart';
import 'myPage.dart';

class Navi extends StatefulWidget {
  const Navi({Key? key}) : super(key: key);

  @override
  State<Navi> createState() => _NaviState();
}

class _NaviState extends State<Navi> {
  int _selectedIndex = Get.arguments?['index'] as int? ?? 1;
  String? userEmail = Get.arguments?['email'] as String?;

  List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>()
  ];

  

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _navigatorKeys[index].currentState!.popUntil((route) => route.isFirst);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await _navigatorKeys[_selectedIndex].currentState!.maybePop();

        // let system handle back button if we're on the first route
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        body: Stack(
          children: [
            _buildOffstageNavigator(0),
            _buildOffstageNavigator(1),
            _buildOffstageNavigator(2),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.qr_code,
                size: 30,
              ),
              label: '적립/사용',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 30),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person_outline,
                size: 30,
              ),
              label: "마이페이지",
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: customer,
          unselectedLabelStyle:
              TextStyle(fontFamily: "GmarketMedium", fontSize: 15, height: 1.5),
          selectedLabelStyle:
              TextStyle(fontFamily: "GmarketMedium", fontSize: 15, height: 1.5),
          unselectedItemColor: Colors.grey,
        ),
      ),
    );
  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context, int index) {
    return {
      '/': (context) {
        return [
          Coupon(userEmail ?? ""),
          Home(userEmail ?? ""),
          MyPage(userEmail ?? ""),
        ].elementAt(index);
      },
    };
  }

  Widget _buildOffstageNavigator(int index) {
    var routeBuilders = _routeBuilders(context, index);

    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => routeBuilders[routeSettings.name]!(context),
          );
        },
      ),
    );
  }
}
