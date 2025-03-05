import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'firebase_options.dart';
import 'package:projectjobb/service/database.dart';
import 'package:projectjobb/user.dart';
import 'package:projectjobb/pages/add_employee.dart';
import 'package:projectjobb/service/auth.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String email = "", password = "";
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  // ฟังก์ชันล็อกอิน
  userLogin() async {
    try {
      // พิมพ์ค่าที่รับมาจากฟอร์ม (ดีบัก)
      print("Attempting login with Email: $email, Password: $password");

      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // ถ้าล็อกอินสำเร็จ
      print("Login successful!");
      if (mounted) {
        print(FirebaseAuth.instance.currentUser!.uid); // เช็คสถานะของพนักงานจากฐานข้อมูล
        final result = await DatabaseMethods()
            .checkEmployeeStatus(FirebaseAuth.instance.currentUser!.uid);
        if (result.docs.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyHomePages()), // ถ้าผ่านการตรวจสอบ ให้ไปที่หน้าหลัก
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
            "คุณไม่สามารถเข้าใช้งานระบบได้",  // หากไม่สามารถใช้งานได้ แสดงข้อความ
            style: TextStyle(fontSize: 20.0),
          )));
        }
      }
    } on FirebaseAuthException catch (e) {
      // ลบข้อความเตือนออกที่นี่
      print("Error: ${e.message}"); // แสดงใน Debug Console
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            //SizedBox(height: 30.0),
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: _formkey,
                child: Column(
                  children: [
                    // ฟิลด์ Email
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 2.0, horizontal: 30.0),
                      decoration: BoxDecoration(
                        color: Color(0xFFedf0f8),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter E-mail'; // ถ้าไม่กรอกอีเมลจะแสดงข้อความนี้
                          }
                          return null;
                        },
                        controller: emailcontroller,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Email...",  // ข้อความที่แสดงในช่องกรอกอีเมล
                          hintStyle: TextStyle(
                              color: Color(0xFFb2b7bf), fontSize: 18.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 30.0),

                    // ฟิลด์ Password
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 2.0, horizontal: 30.0),
                      decoration: BoxDecoration(
                        color: Color(0xFFedf0f8),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Password'; // ถ้าไม่กรอกรหัสผ่านจะแสดงข้อความนี้
                          }
                          return null;
                        },
                        controller: passwordcontroller,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "รหัสผ่าน...",  // ข้อความที่แสดงในช่องกรอกรหัสผ่าน
                          hintStyle: TextStyle(
                              color: Color(0xFFb2b7bf), fontSize: 18.0),
                        ),
                        obscureText: true,
                      ),
                    ),
                    SizedBox(height: 30.0),

                    // ปุ่ม Sign In
                    GestureDetector(
                      onTap: () {
                        if (_formkey.currentState!.validate()) { // ตรวจสอบความถูกต้องของข้อมูล
                          // รับค่าจากฟอร์ม
                          setState(() {
                            email = emailcontroller.text.trim();
                            password = passwordcontroller.text.trim();
                          });
                          userLogin();  // เรียกฟังก์ชันล็อกอิน
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(
                            vertical: 13.0, horizontal: 30.0),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            "เข้าสู่ระบบ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.0),

            // ลิงก์ Forgot Password
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ForgotPassword())); // ถ้าคลิกจะไปหน้ากู้คืนรหัสผ่าน
              },
              child: Text(
                "ลืมรหัสผ่าน?",
                style: TextStyle(
                  color: Color(0xFF8c8e98),
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 40.0),
            SizedBox(
              height: 30.0,
            ),

            // ลิงก์ Sign Up
          ],
        ),
      ),
    );
  }
}
