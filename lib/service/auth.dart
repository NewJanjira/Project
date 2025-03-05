import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:projectjobb/pages/home.dart';
import 'package:projectjobb/service/database.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance; // สร้างตัวแปรสำหรับเชื่อมต่อกับ Firebase Authentication

  // ฟังก์ชันนี้ใช้สำหรับดึงข้อมูลผู้ใช้งานที่เข้าสู่ระบบอยู่
  getCurrentUser() async {
    return await auth.currentUser; // คืนค่าผู้ใช้งานปัจจุบัน
  }

  // ฟังก์ชันสำหรับการเข้าสู่ระบบผ่าน Google
  signInWithGoogle(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance; // สร้างตัวแปรสำหรับเชื่อมต่อกับ Firebase Authentication
    final GoogleSignIn googleSignIn = GoogleSignIn();  // สร้างตัวแปรสำหรับ Google Sign-In

    // เรียกใช้งาน Google Sign-In เพื่อให้ผู้ใช้เลือกบัญชี
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    // ตรวจสอบการเข้าสู่ระบบของผู้ใช้ผ่าน Google
    final GoogleSignInAuthentication? googleSignInAuthentication =
        await googleSignInAccount?.authentication;

    // สร้าง credentials ด้วย idToken และ accessToken จาก Google
    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication?.idToken,
        accessToken: googleSignInAuthentication?.accessToken);

    // ใช้ credentials สำหรับเข้าสู่ระบบ Firebase
    UserCredential result = await firebaseAuth.signInWithCredential(credential);

    // รับข้อมูลของผู้ใช้ที่เข้าสู่ระบบแล้ว
    User? userDetails = result.user;

    if (result != null) {
      // สร้าง Map ของข้อมูลผู้ใช้เพื่อบันทึกใน Firestore
      Map<String, dynamic> userInfoMap = {
        "email": userDetails!.email, // อีเมลผู้ใช้
        "name": userDetails.displayName, // ชื่อผู้ใช้
        "imgUrl": userDetails.photoURL, // รูปโปรไฟล์ผู้ใช้
        "id": userDetails.uid // uid ของผู้ใช้
      };
      // บันทึกข้อมูลผู้ใช้ลงใน Firestore
      await DatabaseMethods()
          .addUser(userDetails.uid, userInfoMap)
          .then((value) {
        // หลังจากบันทึกข้อมูลเสร็จแล้วให้ไปยังหน้า Home
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Home()));
      });
    }
  }
}
