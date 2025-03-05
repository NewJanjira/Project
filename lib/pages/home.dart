import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:projectjobb/service/database.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController namecontroller = new TextEditingController();
  TextEditingController agecontroller = new TextEditingController();
  TextEditingController locationcontroller = new TextEditingController();
  TextEditingController emailcontroller = new TextEditingController();
  TextEditingController passwordcontroller = new TextEditingController();
  String? uid = FirebaseAuth.instance.currentUser?.uid;
  User? currentUser = FirebaseAuth.instance.currentUser;
  late AuthCredential credential;
  var isLogin = false;
  @override
  checkLogin() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          isLogin = true;
        });
      }
    });
  }

  @override
  void initState() {
    checkLogin();
    super.initState();
  }

  Widget allEmployeeDetails() {
    return FutureBuilder<DocumentSnapshot>(
      future: DatabaseMethods().getEmployeePerUser(uid!),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text("No data found"));
        }

        credential = EmailAuthProvider.credential(
          email: snapshot.data?.get("Email"),
          password: snapshot.data?.get("Password"),
        );

        return SingleChildScrollView(
          child: Center(
            child: Container(
              margin: EdgeInsets.only(bottom: 20.0),
              child: Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "ชื่อ: ${snapshot.data?["Name"] ?? "Unknown"}",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              namecontroller.text =
                                  snapshot.data?.get("Name") ?? "";
                              passwordcontroller.text =
                                  snapshot.data?.get("Password") ?? "";
                              final result = await EditEmployeeDetail(
                                  snapshot.data?.get("Id") ?? "");
                              if (result == true) {
                                refreshData(); // เรียกรีเฟรชข้อมูลเมื่อกลับมา
                              }
                            },
                            child: Icon(
                              Icons.edit,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Email : ${snapshot.data?["Email"] ?? "Unknown"}",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "รหัสผ่าน : ${snapshot.data?["Password"] ?? "Unknown"}",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "ข้อมูลส่วนตัว",
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
            Center(child: Container(child: allEmployeeDetails())),
          ],
        ),
      ),
    );
  }

  Future<void> refreshData() async {
    setState(() {}); // Force re-render widget to fetch new data
  }

  Future EditEmployeeDetail(String id) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            content: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.cancel)),
                      SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        "แก้ไขข้อมูลส่วนตัว",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    "ชื่อ",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10.0),
                    decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      controller: namecontroller,
                      decoration: InputDecoration(border: InputBorder.none),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    "รหัสผ่าน",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10.0),
                    decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      controller: passwordcontroller,
                      decoration: InputDecoration(border: InputBorder.none),
                    ),
                  ),
                  Center(
                      child: ElevatedButton(
                          onPressed: () async {
                            currentUser!
                                .reauthenticateWithCredential(credential);
                            currentUser!
                                .updatePassword(passwordcontroller.text);
                            Map<String, dynamic> updateInfo = {
                              "Name": namecontroller.text,
                              "Password": passwordcontroller.text,
                            };
                            await DatabaseMethods()
                                .UpdateEmployeeDetail(id, updateInfo)
                                .then((value) {
                              Navigator.pop(context, true);
                            });
                          },
                          child: Text("อัพเดท")))
                ],
              ),
            ),
          ));
}
