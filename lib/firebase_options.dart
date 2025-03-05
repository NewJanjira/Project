import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projectjobb/pages/add_employee.dart';

class ForgotPassword extends StatefulWidget { // สร้างหน้าจอที่เป็น StatefulWidget เพื่อจัดการสถานะต่าง ๆ
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  String email = ""; // ตัวแปรสำหรับเก็บอีเมลของผู้ใช้ที่กรอก
  TextEditingController mailcontroller = new TextEditingController(); // ตัวควบคุมฟอร์มของ TextField สำหรับอีเมล


  final _formkey = GlobalKey<FormState>();  // ตัวแปรสำหรับสร้างคีย์ฟอร์มเพื่อใช้ตรวจสอบความถูกต้องของข้อมูลที่กรอก

  // ฟังก์ชันสำหรับการรีเซ็ตรหัสผ่าน
  resetPassword() async {
    try {
      // ส่งคำขอรีเซ็ตรหัสผ่านไปยังอีเมล
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // แสดงข้อความ Snackbar เมื่อส่งอีเมลเรียบร้อย
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        "Password Reset Email has been sent !",
        style: TextStyle(fontSize: 20.0),
      )));
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        // หากไม่พบผู้ใช้ในระบบ แสดงข้อความแสดงข้อผิดพลาด
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          "No user found for that email.",
          style: TextStyle(fontSize: 20.0),
        )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: Column(
          children: [
            SizedBox(
              height: 70.0,
            ),
            Container(
              alignment: Alignment.topCenter,
              child: Text(
                "Password Recovery",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              "Enter your mail",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
            Expanded(
                child: Form(
                    key: _formkey, // เชื่อมโยงฟอร์มกับ key
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: ListView(
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 10.0),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.white70, width: 2.0),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) { // ตรวจสอบว่าอีเมลไม่ว่างเปล่า
                                  return 'Please Enter Email'; // แจ้งให้กรอกอีเมล
                                }
                                return null; // หากกรอกแล้วไม่ผิดพลาด
                              },
                              controller: mailcontroller, // ผูกตัวควบคุมกับฟิลด์
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                  hintText: "Email",
                                  hintStyle: TextStyle(
                                      fontSize: 18.0, color: Colors.white),
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: Colors.white70,
                                    size: 30.0,
                                  ),
                                  border: InputBorder.none),
                            ),
                          ),
                          SizedBox(
                            height: 40.0,
                          ),
                          GestureDetector(
                            onTap: () {
                              if (_formkey.currentState!.validate()) { // ตรวจสอบฟอร์มว่าถูกต้องหรือไม่
                                setState(() {
                                  email = mailcontroller.text;  // เก็บอีเมลจาก TextField
                                });
                                resetPassword(); // เรียกฟังก์ชันรีเซ็ตรหัสผ่าน
                              }
                            },
                            child: Container(
                              width: 140,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                child: Text(
                                  "Send Email",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 50.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.white),
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SignUp()));
                                },
                                child: Text(
                                  "Create",
                                  style: TextStyle(
                                      color: Color.fromARGB(225, 184, 166, 6),
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w500),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ))),
          ],
        ),
      ),
    );
  }
} // TODO Implement this library.
