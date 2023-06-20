import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:suge_customer/util/common.dart';

//
class CouponLog extends StatefulWidget {
  final userEmail;

  const CouponLog({required this.userEmail, Key? key}) : super(key: key);

  @override
  State<CouponLog> createState() => _CouponLogState();
}

class _CouponLogState extends State<CouponLog> {
  final int batchSize = 10;
  List<dynamic> savingData = [];
  List<dynamic> usageData = [];
  int savingStart = 0;
  int usageStart = 0;
  bool isSavingLoading = false;
  bool isUsageLoading = false;

  Future<void> fetchInitialSavingData() async {
    List<dynamic> initialData =
        await getSortedSavingData(savingStart, batchSize);
    setState(() {
      savingData = initialData;
      savingStart += batchSize;
    });
  }

  Future<void> fetchInitialUsageData() async {
    List<dynamic> initialData = await getSortedUsageData(usageStart, batchSize);
    setState(() {
      usageData = initialData;
      usageStart += batchSize;
    });
  }

  Future<void> fetchMoreSavingData() async {
    if (isSavingLoading) return;

    setState(() {
      isSavingLoading = true;
    });

    List<dynamic> moreData = await getSortedSavingData(savingStart, batchSize);
    setState(() {
      savingData.addAll(moreData);
      savingStart += batchSize;
      isSavingLoading = false;
    });
  }

  Future<void> fetchMoreUsageData() async {
    if (isUsageLoading) return;

    setState(() {
      isUsageLoading = true;
    });

    List<dynamic> moreData = await getSortedUsageData(usageStart, batchSize);
    setState(() {
      usageData.addAll(moreData);
      usageStart += batchSize;
      isUsageLoading = false;
    });
  }

  Future<List<dynamic>> getSortedSavingData(int start, int limit) async {
    final reference = FirebaseDatabase.instance
        .ref()
        .child('user')
        .orderByChild('email')
        .equalTo(widget.userEmail);

    List<dynamic> dataInRange = [];
    reference.once().then((DatabaseEvent event) async {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> values =
            await event.snapshot.value as Map<dynamic, dynamic>;
        Map<dynamic, dynamic> couponLog = values.values.first['couponLog'];
        if (couponLog != null) {
          couponLog.forEach((key, value) {
            if (value['flag'] == 1) {
              // 적립 내역인 경우만 추가
              DateTime dateTime =
                  DateTime.fromMillisecondsSinceEpoch(value["date"]);

// 원하는 형식으로 출력 (예: "yyyy-MM-dd HH:mm:ss")
              String formattedDate =
                  DateFormat('yyyy-MM-dd', 'ko_KR').format(dateTime);
              String formattedTime =
                  DateFormat('HH:mm', 'ko_KR').format(dateTime);
              Map<dynamic, dynamic> extractedItem = {
                "date": formattedDate,
                "time": formattedTime,
                "flag": value["flag"],
                "count": value["count"],
                "storeName": value["storeName"],
              };
              dataInRange.add(extractedItem);
              print('extSave: $extractedItem');
            }
          });
          dataInRange.sort((a, b) {
            // date를 기준으로 내림차순 정렬
            int dateComparison = b['date'].compareTo(a['date']);
            if (dateComparison != 0) {
              return dateComparison;
            }
            // date가 같을 경우 time을 기준으로 내림차순 정렬
            return b['time'].compareTo(a['time']);
          });
          print('save: $dataInRange');
        }
      } else {
        print('No data found.');
      }
    }).catchError((error) {
      print('Error retrieving data: $error');
    });
    return dataInRange;
  }

  Future<List<dynamic>> getSortedUsageData(int start, int limit) async {
    final reference = FirebaseDatabase.instance
        .ref()
        .child('user')
        .orderByChild('email')
        .equalTo(widget.userEmail);
    List<dynamic> dataInRange = [];
    reference.once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> values =
            event.snapshot.value as Map<dynamic, dynamic>;
        Map<dynamic, dynamic> couponLog = values.values.first['couponLog'];
        print(couponLog);
        if (couponLog != null) {
          couponLog.forEach((key, value) {
            if (value['flag'] == 2) {
              // 사용 내역인 경우만 추가
              DateTime dateTime =
                  DateTime.fromMillisecondsSinceEpoch(value["date"]);

              String formattedDate =
                  DateFormat('yyyy-MM-dd', 'ko_KR').format(dateTime);
              String formattedTime =
                  DateFormat('HH:mm', 'ko_KR').format(dateTime);
              Map<dynamic, dynamic> extractedItem = {
                "date": formattedDate,
                "time": formattedTime,
                "flag": value["flag"],
                "count": value["count"],
                "storeName": value["storeName"],
              };
              print('extUsage: $extractedItem');
              dataInRange.add(extractedItem);
            }
          });
          print('usage: $dataInRange');
          dataInRange.sort((a, b) {
            // date를 기준으로 내림차순 정렬
            int dateComparison = b['date'].compareTo(a['date']);
            if (dateComparison != 0) {
              return dateComparison;
            }
            // date가 같을 경우 time을 기준으로 내림차순 정렬
            return b['time'].compareTo(a['time']);
          });
        }
      } else {
        print('No data found.');
      }
    }).catchError((error) {
      print('Error retrieving data: $error');
    });
    return dataInRange;
  }

  bool _isSavingScrolledToBottom(ScrollNotification scrollNotification) {
    if (scrollNotification is ScrollEndNotification &&
        scrollNotification.metrics.extentAfter == 0) {
      return true;
    }
    return false;
  }

  bool _isUsageScrolledToBottom(ScrollNotification scrollNotification) {
    if (scrollNotification is ScrollEndNotification &&
        scrollNotification.metrics.extentAfter == 0) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    initializeDateFormatting("ko_KR");
    fetchInitialSavingData();
    fetchInitialUsageData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 60,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.centerLeft,
          child: const Text("쿠폰 사용 내역",
              style: TextStyle(
                  fontFamily: 'GmarketMedium', fontSize: 30, color: customer)),
        ),
        SizedBox(
          height: 20,
        ),
        Expanded(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  labelColor: Colors.black,
                  labelStyle: textStyle20B,
                  indicatorColor: customer,
                  tabs: [
                    Tab(text: '적립'),
                    Tab(text: '사용'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      ListView.builder(
                        itemCount: savingData.length + 1,
                        itemBuilder: (context, index) {
                          if (index < savingData.length) {
                            dynamic item = savingData[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: ListTile(
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item['date'],
                                      style: textStyle15,
                                    ),
                                    Text(
                                      item['time'],
                                      style: textStyle15,
                                    ),
                                  ],
                                ),
                                subtitle: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        item['storeName'],
                                        style: textStyle15BBlack,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "${item['count']}개",
                                        style: textStyle15BBlack,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else if (isSavingLoading) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else {
                            return null;
                          }
                        },
                        // Add your own itemExtent if you want to set a fixed height for each item
                        // itemExtent: 100,
                        // Add your own separatorBuilder if you want to customize the separators
                        // separatorBuilder: (context, index) => Divider(),
                        // Add your own controller and physics if needed
                        // controller: ScrollController(),
                        // physics: ScrollPhysics(),
                      ),
                      ListView.builder(
                        itemCount: usageData.length + 1,
                        itemBuilder: (context, index) {
                          if (index < usageData.length) {
                            dynamic item = usageData[index];
                            return ListTile(
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item['date'],
                                    style: textStyle15,
                                  ),
                                  Text(
                                    item['time'],
                                    style: textStyle15,
                                  ),
                                ],
                              ),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      item['storeName'],
                                      style: textStyle15BBlack,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "${item['count']}개",
                                      style: textStyle15BBlack,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else if (isUsageLoading) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else {
                            return null;
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
