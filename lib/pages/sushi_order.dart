import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projectjobb/pages/sushi_order_detail.dart';

import 'package:projectjobb/service/database.dart';

class SushiOrder extends StatefulWidget {
  const SushiOrder({super.key});

  @override
  State<SushiOrder> createState() => _SushiOrderState();
}

class _SushiOrderState extends State<SushiOrder> {
  // ตัวแปรสำหรับควบคุมการกรอกข้อมูล
  TextEditingController namecontroller = new TextEditingController();
  TextEditingController pricecontroller = new TextEditingController();

  // ตัวแปรสำหรับ Stream ที่จะใช้ดึงข้อมูลรายการสั่งซื้อ
  @override
  Stream? OrderStream;

  // ฟังก์ชันเพื่อดึงข้อมูลการสั่งซูชิจาก Firestore
  getontheload() async {
    OrderStream = await DatabaseMethods().getOrder(); // ดึงข้อมูลการสั่งซื้อทั้งหมด
    setState(() {}); // รีเฟรชหน้าจอเมื่อได้รับข้อมูล
  }

  // ฟังก์ชันที่ใช้ดึงชื่อพนักงานจาก id ที่เก็บใน Firebase
  Future<String> getEmployeeName(String id) async {
    // ดึงข้อมูลชื่อพนักงานจาก collection "Employee"
    QuerySnapshot employeeNameSnapshot = await FirebaseFirestore.instance
        .collection("Employee")
        .where("Id", isEqualTo: id)
        .get();
    if (employeeNameSnapshot.docs.isEmpty) {
      print('No employee found with name: ' + id); // ถ้าไม่พบพนักงาน
    }
    DocumentSnapshot doc = employeeNameSnapshot.docs.first;
    Map<String, dynamic> employeeName = doc.data() as Map<String, dynamic>;
    print(employeeName["Name"]);
    return employeeName["Name"].toString(); // คืนค่าชื่อพนักงาน
  }

  // ฟังก์ชัน initState() เพื่อเรียกข้อมูลเมื่อเริ่มต้นหน้า
  @override
  void initState() {
    getontheload(); // เรียกฟังก์ชันดึงข้อมูล
    super.initState();
  }

  // ฟังก์ชันแสดงรายละเอียดรายการสั่งซื้อทั้งหมด
  Widget allOrderDetails() {
    return StreamBuilder(
        stream: OrderStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "วันที่ : " +
                                        DateFormat('dd/MM/yyyy')
                                            .format(ds["Date"].toDate())
                                            .toString(),
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      text: "ชื่อพนักงาน : ",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      children: [
                                        WidgetSpan(
                                          child: FutureBuilder<String>(
                                            future:
                                                getEmployeeName(ds["Employee"]),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Text(
                                                  "Loading...",
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                );
                                              } else if (snapshot.hasError) {
                                                return Text(
                                                  "Error",
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                );
                                              } else if (!snapshot.hasData ||
                                                  snapshot.data!.isEmpty) {
                                                return Text(
                                                  "No Name Found",
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                );
                                              } else {
                                                return Text(
                                                  snapshot.data!,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              OrderDetail(id: ds["Id"]),
                                        ),
                                      );
                                    },
                                    child: Icon(
                                      Icons.visibility_sharp,
                                      color: Colors.black,
                                      size: 36.0, // ขนาดของไอคอน
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "ยอดรวม : " + ds["TotalAmount"].toString(),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  })
              : Container();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "รายการสั่งซื้อ",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0),
        child: Column(
          children: [
            Expanded(child: allOrderDetails()),
          ],
        ),
      ),
    );
  }
}
