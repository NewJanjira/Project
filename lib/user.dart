import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projectjobb/login.dart';
import 'package:projectjobb/pages/dashboard.dart';
import 'package:projectjobb/pages/detect_sushi.dart';
import 'package:projectjobb/pages/employee_page.dart';
import 'package:projectjobb/pages/homesushi.dart';
import 'package:projectjobb/pages/sushi_order.dart';
import 'package:projectjobb/service/database.dart';
import 'package:projectjobb/pages/home.dart';

class MyHomePages extends StatefulWidget {
  const MyHomePages({super.key});

  @override
  State<MyHomePages> createState() => _MyHomePagsState();
}

class _MyHomePagsState extends State<MyHomePages> {
  String? uid = FirebaseAuth.instance.currentUser?.uid; // ดึง UID ของผู้ใช้ปัจจุบันจาก Firebase
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>( // ใช้ FutureBuilder เพื่อตรวจสอบข้อมูลของพนักงานจาก Firestore
        future: DatabaseMethods().getEmployeePerUser(uid!), // ดึงข้อมูลพนักงานจาก UID
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center( // ถ้ายังโหลดข้อมูลอยู่ จะแสดงหน้าจอที่มีการโหลด
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator( // การแสดงโหลดข้อมูล
                    strokeWidth: 6.0,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
            );
          } else {
            // ถ้าโหลดข้อมูลเสร็จแล้ว
            String fullname = snapshot.data?.get("Name"); // ดึงชื่อผู้ใช้งาน
            String email = snapshot.data?.get("Email"); // ดึงอีเมลของผู้ใช้งาน
            String firstletter = fullname[0]; // ดึงตัวอักษรแรกของชื่อเพื่อใช้เป็นตัวอักษรในรูปโปรไฟล์
            return Scaffold(
                drawer: Drawer(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      UserAccountsDrawerHeader(  // ส่วนแสดงชื่อผู้ใช้งานในเมนู
                        accountName: Text(fullname!),
                        accountEmail: Text(email),
                        currentAccountPicture: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Text(
                            firstletter.toUpperCase(),
                            style: TextStyle(fontSize: 40.0),
                          ),
                        ),
                      ),

                      // เมนูต่างๆ
                      ListTile(
                        leading: Icon(Icons.person),
                        title: const Text('ข้อมูลส่วนตัว'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Home()),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.logout),
                        title: const Text('ออกจากระบบ'),
                        onTap: () {
                          Navigator.pop(context);
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return SizedBox(
                                height: 200,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      const Text(
                                          'คุณต้องการออกระบบใช่หรือไม่ ?'),
                                      ElevatedButton(
                                        child: const Text('ใช่'),
                                        onPressed: () async {
                                          await DatabaseMethods().logout();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => LogIn()),
                                          );
                                        },
                                      ),
                                      ElevatedButton(
                                        child: const Text('ไม่'),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                appBar: AppBar(title: Text('หน้าจอหลัก')),
                body: Center(
                    child: (snapshot.data?["Role"] == "Owner") // ถ้าเป็นเจ้าของจะแสดงปุ่มเมนูที่แตกต่าง
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(height: 20.0),
                              // เพิ่มระยะห่างด้านบน 20.0
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(
                                      200, 50), // ขยายขนาดปุ่ม (กว้าง x สูง)
                                ),
                                child: Text('จัดการข้อมูลซูชิ'),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomeSushi()),
                                ),
                              ),

                              SizedBox(height: 10.0),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(
                                      200, 50), // ขยายขนาดปุ่ม (กว้าง x สูง)
                                ),
                                child: Text('จัดการข้อมูลพนักงาน'),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EmployeePage()),
                                ),
                              ),
                              SizedBox(height: 10.0),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(
                                      200, 50), // ขยายขนาดปุ่ม (กว้าง x สูง)
                                ),
                                child: Text('สแกน'),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => YoloVideo()),
                                ),
                              ),
                              SizedBox(height: 10.0),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(
                                      200, 50), // ขยายขนาดปุ่ม (กว้าง x สูง)
                                ),
                                child: Text('ดูประวัติการสั่งซื้อ'),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SushiOrder()),
                                ),
                              ),
                              SizedBox(height: 10.0),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(
                                      200, 50), // ขยายขนาดปุ่ม (กว้าง x สูง)
                                ),
                                child: Text('ดูสรุปยอดขาย'),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Dashboard()),
                                ),
                              ),
                            ],
                          )
                        : Column(children: [
                            SizedBox(height: 10.0),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize:
                                    Size(200, 50), // ขยายขนาดปุ่ม (กว้าง x สูง)
                              ),
                              child: Text('สแกน'),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => YoloVideo()),
                              ),
                            ),
                            SizedBox(height: 10.0),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize:
                                    Size(200, 50), // ขยายขนาดปุ่ม (กว้าง x สูง)
                              ),
                              child: Text('ดูประวัติการสั่งซื้อ'),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SushiOrder()),
                              ),
                            ),
                          ])));
          }
        });
  }
}
