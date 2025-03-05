import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projectjobb/pages/add_employee.dart';
import 'package:projectjobb/service/database.dart';

class HomeEmployee extends StatefulWidget {
  const HomeEmployee({super.key, Object? employeeData});

  @override
  State<HomeEmployee> createState() => _HomeState();
}

class _HomeState extends State<HomeEmployee> {
  // ตัวแปรสำหรับควบคุม TextField
  TextEditingController namecontroller = new TextEditingController();
  TextEditingController emailcontroller = new TextEditingController();

  @override
  Stream? EmployeeStream;

  // ฟังก์ชันโหลดข้อมูลพนักงานจากฐานข้อมูล
  getontheload() async {
    EmployeeStream = await DatabaseMethods().getEmployeDetails("Yes");
    setState(() {});
  }

  @override
  void initState() {
    getontheload(); // โหลดข้อมูลพนักงานเมื่อหน้าถูกสร้าง
    super.initState();
  }

  // แสดงข้อมูลพนักงานทั้งหมด
  Widget allEmployeeDetails() {
    return StreamBuilder(
        stream: EmployeeStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
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
                                  GestureDetector(
                                      onTap: () async {
                                        namecontroller.text = ds["Name"];
                                        final result =
                                            await EditEmployeeDetail(ds["Id"]);
                                        if (result == true) {
                                          refreshData();
                                        }
                                      },
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.black,
                                      )),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  GestureDetector(
                                      onTap: () async {
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
                                                        'คุณต้องการลบพนักงานออกจากระบบใช่หรือไม่ ?'),
                                                    ElevatedButton(
                                                      child: const Text('ใช่'),
                                                      onPressed: () async {
                                                        await DatabaseMethods()
                                                            .changeStatusEmployeeDetail(
                                                                ds["Id"], "No");
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
                                        Icons.delete,
                                        color: Colors.black,
                                      )),
                                ],
                              ),
                              Text(
                                "Email : " + ds["Email"],
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "รหัสผ่าน : " + ds["Password"],
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
              : Container();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SignUp()));
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "ข้อมูลพนักงาน",
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
            Expanded(child: allEmployeeDetails()),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันรีเฟรชข้อมูลพนักงาน
  Future<void> refreshData() async {
    setState(() {}); // Force re-render widget to fetch new data
  }

  // ฟังก์ชันแก้ไขข้อมูลพนักงาน
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
                        height: 20.0,
                      ),
                      Text(
                        "แก้ไขข้อมูลพนักงาน",
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

                  //เพิ่มฟอร์มสำหรับแก้ไขข้อมูลที่นี่
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

                  Center(
                      child: ElevatedButton(
                          onPressed: () async {
                            Map<String, dynamic> updateInfo = {
                              "Name": namecontroller.text,
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
