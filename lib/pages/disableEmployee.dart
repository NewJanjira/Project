import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:projectjobb/service/database.dart';

class DisableEmployee extends StatefulWidget {
  const DisableEmployee({super.key, Object? employeeData});

  @override
  State<DisableEmployee> createState() => _DisableEmployee();
}

class _DisableEmployee extends State<DisableEmployee> {
  // ตัวแปรสำหรับควบคุมช่องป้อนข้อมูล
  TextEditingController namecontroller = new TextEditingController();
  TextEditingController emailcontroller = new TextEditingController();

  @override
  Stream? EmployeeStream; // ตัวแปรสำหรับเก็บข้อมูลพนักงานที่ถูกลบ

  // ฟังก์ชันโหลดข้อมูลพนักงานที่ถูกลบจากฐานข้อมูล
  getontheload() async {
    EmployeeStream = await DatabaseMethods().getEmployeDetails("No");
    setState(() {});
  }

  @override
  void initState() {
    getontheload(); // เรียกใช้ฟังก์ชันโหลดข้อมูลเมื่อเริ่มต้นหน้า
    super.initState();
  }

  // ฟังก์ชันแสดงข้อมูลพนักงานที่ถูกลบ
  Widget allEmployeeDetails() {
    return StreamBuilder(
        stream: EmployeeStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.docs.length,  // จำนวนรายการข้อมูลพนักงาน
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index]; // ดึงข้อมูลพนักงานแต่ละคน
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
                                    "ชื่อ : " + ds["Name"],
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Spacer(),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  GestureDetector(
                                      onTap: () async {  // แสดง Modal ยืนยันการนำพนักงานกลับเข้าระบบ
                                        showModalBottomSheet<void>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return SizedBox(
                                              height: 200,
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    const Text(
                                                        'คุณต้องการนำพนักงานกลับเข้ามาระบบใช่หรือไม่ ?'),
                                                    ElevatedButton(
                                                      child: const Text('ใช่'),
                                                      onPressed: () async {
                                                        // เปลี่ยนสถานะพนักงานกลับเป็น "Yes" ในฐานข้อมูล
                                                        await DatabaseMethods()
                                                            .changeStatusEmployeeDetail(
                                                                ds["Id"],
                                                                "Yes");
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                    ElevatedButton(
                                                      child: const Text('ไม่'),
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Icon(
                                        Icons.refresh_rounded,
                                        color: Colors.black,
                                      )),
                                ],
                              ),
                              Text(
                                "Email : " + ds["Email"], // แสดงอีเมลพนักงาน
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "รหัสผ่าน : " + ds["Password"], // แสดงรหัสผ่านพนักงาน
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
              : Container(); // หากไม่มีข้อมูล ไม่แสดงอะไรเลย
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
              "ข้อมูลพนักงานที่ถูกลบ",
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
            Expanded(child: allEmployeeDetails()),  // แสดงรายการพนักงานที่ถูกลบ
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันรีเฟรชข้อมูล
  Future<void> refreshData() async {
    setState(() {}); // Force re-render widget to fetch new data
  }
}
