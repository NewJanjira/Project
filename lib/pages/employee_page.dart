import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projectjobb/pages/homeemployee.dart';

import 'package:projectjobb/pages/disableEmployee.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePage();
}

class _EmployeePage extends State<EmployeePage> {
  String? uid = FirebaseAuth.instance.currentUser?.uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('ข้อมูลพนักงาน')),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            SizedBox(height: 20.0),
            // เพิ่มระยะห่างด้านบน 20.0
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50), // ขยายขนาดปุ่ม (กว้าง x สูง)
              ),
              child: Text('ข้อมูลพนักงานที่ทำงาน'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeEmployee()),
              ),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50), // ขยายขนาดปุ่ม (กว้าง x สูง)
              ),
              child: Text('ข้อมูลพนักงานที่ระงับ'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DisableEmployee()),
              ),
            ),
          ]),
        ));
  }
}
