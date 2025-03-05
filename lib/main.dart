import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projectjobb/user.dart';

import 'package:projectjobb/login.dart';

//final FirebaseAuth _auth = FirebaseAuth.instance;


// ฟังก์ชันหลักของแอปพลิเคชัน (จุดเริ่มต้นการทำงาน)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // ให้ Flutter ทำงานพร้อมระบบทั้งหมดก่อนเริ่มแอป
  await Firebase.initializeApp( // เริ่มต้นใช้งาน Firebase ด้วยค่าการตั้งค่าที่กำหนด
    options: FirebaseOptions(
      apiKey: "AIzaSyBiAav9yqcITJi5RTzIyLYy4iUlHlKCDN0",
      appId: "1:552387575051:android:48da9efce4e78ac405b60e",
      messagingSenderId: "552387575051",
      projectId: "myprojectjob-3201f",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Login',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false, // ซ่อนแถบ Debug
      home: AuthWrapper(),
      routes: {
        '/login': (context) => LogIn(), // เส้นทางไปหน้าล็อกอิน
        '/home': (context) => MyHomePages(), // เส้นทางไปหน้าหลักของผู้ใช้
      },
    );
  }
}

// คลาสสำหรับตรวจสอบสถานะผู้ใช้ (ล็อกอินหรือยัง)
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    // เช็คว่าสถานะผู้ใช้ล็อกอินอยู่หรือไม่
    if (_auth.currentUser != null) { // ถ้ามีผู้ใช้ล็อกอินอยู่
      return MyHomePages(); // แสดงหน้าหลักของผู้ใช้
    } else { // ถ้ายังไม่มีการล็อกอิน
      return LogIn(); // แสดงหน้าล็อกอิน
    }
  }
}
