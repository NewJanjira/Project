import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projectjobb/service/database.dart';

// ตัวแปรสำหรับเก็บข้อมูลการสั่งซื้อ
List<Map<String, dynamic>> list = [];

class OrderDetail extends StatelessWidget {
  const OrderDetail({super.key, required this.id});

  final String? id; // ตัวแปรเก็บ id ของการสั่งซื้อ

  // ฟังก์ชัน queryOrderDetail ใช้ดึงข้อมูลรายละเอียดการสั่งซื้อจาก Firebase
  Future<List<Map<String, dynamic>>> queryOrderDetail(String id) async {
    // ดึงข้อมูลการสั่งซื้อจาก Firestore ด้วย id ที่ส่งเข้ามา
    QuerySnapshot<Map<String, dynamic>> data =
        await DatabaseMethods().getOrderDetail(id);
    // แปลงข้อมูลจาก Firestore ให้เป็น List ของ Map
    List<Map<String, dynamic>> orderDetails = data.docs.map((orderDetail) {
      return {
        'name': orderDetail['name'],  // ชื่อซูชิ
        'quantity': orderDetail['quantity'], // จำนวนซูชิ
        'price': orderDetail['price'], // ราคาต่อชิ้น
        'total': orderDetail['total']  // ราคารวม
      };
    }).toList();
    return orderDetails;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดการสั่งซื้อ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            // กลับไปหน้า YoloVideo
          },
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>( // ใช้ FutureBuilder ในการดึงข้อมูล
          future: queryOrderDetail(id!), // เรียกฟังก์ชัน queryOrderDetail เพื่อดึงข้อมูลการสั่งซื้อ
          builder: (context, snapshot) { // ตรวจสอบสถานะของการดึงข้อมูล
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator()); // แสดง progress indicator ระหว่างรอข้อมูล
            } else if (snapshot.hasError) {
              return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}')); // แสดงข้อความผิดพลาดหากเกิดข้อผิดพลาด
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('ไม่มีข้อมูลการสั่งซื้อ'));  // ถ้าไม่มีข้อมูลจะแสดงข้อความนี้
            }

            final sushiOrders = snapshot.data!; // ดึงข้อมูลที่ได้จาก FutureBuilder

            return SizedBox.expand(
              child: SingleChildScrollView( // ทำให้ข้อมูลสามารถเลื่อนขึ้น-ลงได้
                scrollDirection: Axis.vertical, // ตั้งค่าการเลื่อนในแนวตั้ง
                child: DataTable( // ใช้ DataTable เพื่อแสดงข้อมูลในรูปแบบตาราง
                  columns: _createColumn(),  // สร้างคอลัมน์
                  rows: _createRow(sushiOrders), // สร้างแถวจากข้อมูลการสั่งซื้อ
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ฟังก์ชันสำหรับสร้างคอลัมน์ของ DataTable
  List<DataColumn> _createColumn() {
    return [
      DataColumn(
        label: Text("ประเภทซูชิ"), // ชื่อคอลัมน์ประเภทซูชิ
      ),
      DataColumn(
        label: Text("จำนวน"), // ชื่อคอลัมน์จำนวน
      ),
      DataColumn(
        label: Text("ราคา"), // ชื่อคอลัมน์ราคา
      ),
      DataColumn(
        label: Text("ราคารวม"), // ชื่อคอลัมน์ราคารวม
      ),
    ];
  }

  List<DataRow> _createRow(List<Map<String, dynamic>> sushi) {
    return sushi!.map((data) { // ทำการแปลงข้อมูลทุกตัวใน List
      return DataRow(cells: [
        DataCell(
          Text(data['name']), // แสดงชื่อซูชิ
        ),
        DataCell(
          Text(data['quantity'].toString()), // แสดงจำนวนซูชิ
        ),
        DataCell(
          Text(data['price'].toString()), // แสดงราคา
        ),
        DataCell(
          Text(data['total'].toString()), // แสดงราคารวม
        ),
      ]);
    }).toList(); // แปลงให้เป็น List ของ DataRow
  }
}
