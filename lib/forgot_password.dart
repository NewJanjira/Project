import 'package:flutter/material.dart';
import 'package:projectjobb/pages/add_employee.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  get borderRadius => null; // ตัวแปรนี้ไม่ได้ใช้งานจริงในการคำนวณ ค่า default เป็น null

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
            Expanded(
                child: Form(
                    child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: ListView(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 10.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white70, width: 2.0),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  SizedBox(
                    height: 40.00,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 140,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
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
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
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
                      ),
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
}
