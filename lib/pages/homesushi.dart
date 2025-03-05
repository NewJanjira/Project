import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projectjobb/pages/sushi.dart';
import 'package:projectjobb/service/database.dart';

class HomeSushi extends StatefulWidget {
  const HomeSushi({super.key, Object? employeeData});

  @override
  State<HomeSushi> createState() => _HomeState();
}

// สร้าง StatefulWidget เพื่อจัดการสถานะของหน้าจอ
class _HomeState extends State<HomeSushi> {
  TextEditingController pricecontroller = new TextEditingController();

  // ตัวแปร Stream สำหรับดึงข้อมูลซูชิจากฐานข้อมูล
  @override
  Stream? SushiStream;

  // ฟังก์ชันในการโหลดข้อมูลซูชิจากฐานข้อมูล
  getontheload() async {
    SushiStream = await DatabaseMethods().getSushiDetails();
    setState(() {}); // รีเฟรชหน้าจอหลังจากดึงข้อมูล
  }

  // ฟังก์ชันที่ทำงานเมื่อเริ่มต้นใช้งานหน้าจอ
  @override
  void initState() {
    getontheload();  // เรียกใช้ฟังก์ชันดึงข้อมูล
    super.initState();
  }

  // ฟังก์ชันที่ใช้แสดงรายละเอียดของซูชิ
  Widget allSushiDetails() {
    return StreamBuilder(
        stream: SushiStream, // เชื่อมต่อกับ stream
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.docs.length, // จำนวนซูชิที่แสดง
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
                                    "ชื่อซูชิ : " + ds["Name"], // แสดงชื่อซูชิ
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Spacer(),
                                  GestureDetector(
                                      onTap: () async {
                                        pricecontroller.text =
                                            ds["Price"].toString();
                                        final result =
                                            await EditSushiDetail(ds["Id"]);  // แก้ไขข้อมูลซูชิ
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
                                ],
                              ),
                              Text(
                                "ราคา : " + ds["Price"].toString(),
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
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "ข้อมูลซูชิ",
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
            Expanded(child: allSushiDetails()), // แสดงรายละเอียดซูชิ
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันสำหรับรีเฟรชข้อมูล
  Future<void> refreshData() async {
    setState(() {}); // Force re-render widget to fetch new data
  }

  Future EditSushiDetail(String id) => showDialog(
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
                        "แก้ไขข้อมูลซูชิ",
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
                    "ราคา",
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
                      controller: pricecontroller,
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
                              "Price": int.parse(pricecontroller.text), // อัพเดทราคา
                            };
                            await DatabaseMethods()
                                .UpdateSushiDetail(id, updateInfo)  // เรียกใช้ฟังก์ชันอัพเดทข้อมูล
                                .then((value) {
                              Navigator.pop(context, true); // ปิด Dialog หลังจากอัพเดท
                            });
                          },
                          child: Text("อัพเดท")))
                ],
              ),
            ),
          ));
}
