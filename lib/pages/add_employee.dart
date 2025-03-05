import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projectjobb/pages/homeemployee.dart';
import 'package:projectjobb/service/database.dart';
import 'package:random_string/random_string.dart';


class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String email = "", name = "";  // กำหนดตัวแปรสำหรับเก็บอีเมลและชื่อ
  TextEditingController namecontroller = new TextEditingController(); // ตัวจัดการข้อความสำหรับชื่อ
  TextEditingController mailcontroller = new TextEditingController(); // ตัวจัดการข้อความสำหรับอีเมล
  String Id = randomAlphaNumeric(10); // สร้างรหัสผ่านแบบสุ่ม 10 ตัวอักษร

  final _formkey = GlobalKey<FormState>(); // กำหนด Key สำหรับแบบฟอร์ม


  // ฟังก์ชันสำหรับการสมัครสมาชิก
  registration() async {
    if (namecontroller.text != "" && mailcontroller.text != "") { // ตรวจสอบว่าไม่ได้ปล่อยช่องว่าง
      try {
        // สมัครสมาชิกด้วยอีเมลและรหัสผ่าน
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: Id);
        // เตรียมข้อมูลพนักงานสำหรับบันทึกในฐานข้อมูล
        Map<String, dynamic> employeeInfoMap = {
          "Name": namecontroller.text,
          "Id": FirebaseAuth.instance.currentUser!.uid,
          "Role": "Employee", // ระบุบทบาทเป็นพนักงาน
          "Status": "Yes", // สถานะการทำงาน
          "Email": mailcontroller.text,
          "Password": Id, // รหัสผ่านที่สร้าง
        };

        // บันทึกข้อมูลพนักงานลงฐานข้อมูล
        await DatabaseMethods()
            .addEmployeeDetails(
                employeeInfoMap, FirebaseAuth.instance.currentUser!.uid)
            .then((value) {
          // แสดงข้อความเมื่อสมัครสำเร็จ
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
            "Registered Successfully",
            style: TextStyle(fontSize: 20.0),
          )));
          // ไปยังหน้า HomeEmployee
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomeEmployee()));
        });
      } on FirebaseAuthException catch (e) { // ดักจับข้อผิดพลาดจาก Firebase
        if (e.code == "email-already-in-use") { // กรณีอีเมลถูกใช้ไปแล้ว
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.black,
              content: Text(
                "Account Already exists", // แจ้งเตือนว่าบัญชีมีอยู่แล้ว
                style: TextStyle(fontSize: 18.0),
              )));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("เพิ่มพนักงาน")), // ชื่อหัวข้อแอป
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Form(
                key: _formkey,  // กำหนด Key สำหรับแบบฟอร์ม

                child: Column(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 2.0, horizontal: 30.0),
                      decoration: BoxDecoration(
                          color: Color(0xFFedf0f8),
                          borderRadius: BorderRadius.circular(30)),
                      child: TextFormField(
                        validator: (value) { // ตรวจสอบการกรอกชื่อ
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Name'; // แจ้งเตือนเมื่อไม่ได้กรอกชื่อ
                          }
                          return null;
                        },
                        controller: namecontroller, // ตัวควบคุมข้อความสำหรับชื่อ
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "ชื่อ",
                            hintStyle: TextStyle(
                                color: Color(0xFFb2b7bf), fontSize: 18.0)),
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),

                    // ช่องกรอกอีเมล
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 2.0, horizontal: 30.0),
                      decoration: BoxDecoration(
                          color: Color(0xFFedf0f8),
                          borderRadius: BorderRadius.circular(30)),
                      child: TextFormField(
                        validator: (value) { // ตรวจสอบการกรอกอีเมล
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Email'; // แจ้งเตือนเมื่อไม่ได้กรอกอีเมล
                          }
                          return null;
                        },
                        controller: mailcontroller,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Email",
                            hintStyle: TextStyle(
                                color: Color(0xFFb2b7bf), fontSize: 18.0)),
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),

                    // ปุ่มยืนยัน
                    GestureDetector(
                      onTap: () { // เมื่อกดปุ่ม
                        if (_formkey.currentState!.validate()) {  // ตรวจสอบความถูกต้องของฟอร์ม
                          setState(() {
                            email = mailcontroller.text; // เก็บค่าอีเมลจากช่องกรอก
                            name = namecontroller.text; // เก็บค่าชื่อจากช่องกรอก
                          });
                        }
                        registration(); // เรียกฟังก์ชันการสมัครสมาชิก
                      },
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(
                              vertical: 13.0, horizontal: 30.0),
                          decoration: BoxDecoration(
                              color: Color(0xFF273671),
                              borderRadius: BorderRadius.circular(30)),
                          child: Center(
                            child: Text(
                              "ยืนยัน",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.w500),
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 40.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [],
            ),
            SizedBox(
              height: 40.0,
            ),
          ],
        ),
      ),
    );
  }
}
