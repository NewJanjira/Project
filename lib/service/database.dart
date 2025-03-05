import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseMethods {
  final _auth = FirebaseAuth.instance;  // ตัวแปรสำหรับใช้งาน Firebase Authentication

  // CREATE: ฟังก์ชันสำหรับเพิ่มข้อมูลพนักงานใหม่
  Future addEmployeeDetails(
      Map<String, dynamic> employeeInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("Employee") // เข้าถึงคอลเล็กชัน "Employee"
        .doc(id) // เลือกเอกสารที่มี id ที่กำหนด
        .set(employeeInfoMap); // บันทึกข้อมูลพนักงานใหม่
  }

  // READ: ฟังก์ชันสำหรับดึงข้อมูลพนักงานที่มีสถานะและบทบาทที่กำหนด
  Future<Stream<QuerySnapshot>> getEmployeDetails(String NoYes) async {
    return await FirebaseFirestore.instance
        .collection("Employee") // เข้าถึงคอลเล็กชัน "Employee"
        .where("Role", isEqualTo: "Employee") // กรองข้อมูลโดยเลือก "Role" เป็น "Employee"
        .where("Status", isEqualTo: NoYes) // กรองข้อมูลโดยเลือก "Status" เป็น "Yes" หรือ "No"
        .snapshots();  // คืนค่า Stream ของข้อมูลพนักงานที่ตรงกับเงื่อนไข
  }

  // READ: ฟังก์ชันสำหรับดึงข้อมูลพนักงานเฉพาะของผู้ใช้ตาม uid
  Future<DocumentSnapshot> getEmployeePerUser(String uid) {
    return FirebaseFirestore.instance.collection('Employee').doc(uid).get(); // ดึงเอกสารพนักงานตาม uid
  }

  // CHECK: ฟังก์ชันสำหรับตรวจสอบสถานะของพนักงาน
  checkEmployeeStatus(String uid) async {
    return await FirebaseFirestore.instance
        .collection('Employee') // เข้าถึงคอลเล็กชัน "Employee"
        .where("Id", isEqualTo: uid) // ค้นหาตาม "Id" ที่ตรงกับ uid
        .where("Status", isEqualTo: "Yes") // ตรวจสอบว่า "Status" เป็น "Yes
        .get();  // คืนค่าผลลัพธ์ของการค้นหา
  }

  // UPDATE: ฟังก์ชันสำหรับอัปเดตข้อมูลพนักงานE
  Future UpdateEmployeeDetail(
      String id, Map<String, dynamic> updateInfo) async {
    return await FirebaseFirestore.instance
        .collection("Employee")  // เข้าถึงคอลเล็กชัน "Employee"
        .doc(id)  // เลือกเอกสารที่มี id ที่กำหนด
        .update(updateInfo); // อัปเดตข้อมูลพนักงาน
  }

// DELETE: ฟังก์ชันสำหรับเปลี่ยนสถานะพนักงาน
  Future changeStatusEmployeeDetail(String id, String status) async {
    return await FirebaseFirestore.instance
        .collection("Employee") // เข้าถึงคอลเล็กชัน "Employee"
        .doc(id) // เลือกเอกสารที่มี id ที่กำหนด
        .update({"Status": status}); // อัปเดตสถานะของพนักงาน
  }

  // READ: ฟังก์ชันสำหรับดึงข้อมูลซูชิทั้งหมด
  Future<Stream<QuerySnapshot>> getSushiDetails() async {
    return await FirebaseFirestore.instance.collection("Sushi").snapshots(); // คืนค่า Stream ของข้อมูลซูชิทั้งหมด
  }

  // UPDATE: ฟังก์ชันสำหรับอัปเดตข้อมูลซูชิ
  Future UpdateSushiDetail(String id, Map<String, dynamic> updateInfo) async {
    return await FirebaseFirestore.instance
        .collection("Sushi") // เข้าถึงคอลเล็กชัน "Sushi"
        .doc(id) // เลือกเอกสารที่มี id ที่กำหนด
        .update(updateInfo); // อัปเดตข้อมูลซูชิ
  }

// DELETE : ฟังก์ชันสำหรับลบข้อมูลซูชิ
  Future deleteSushiDetail(String id) async {
    return await FirebaseFirestore.instance
        .collection("Sushi") // เข้าถึงคอลเล็กชัน "Sushi"
        .doc(id) // เลือกเอกสารที่มี id ที่กำหนด
        .delete();  // ลบข้อมูลซูชิ
  }

  // CREATE: ฟังก์ชันสำหรับเพิ่มข้อมูลซูชิใหม่
  Future addSushi(String userId, Map<String, dynamic> userInfoMap) {
    return FirebaseFirestore.instance
        .collection("Sushi") // เข้าถึงคอลเล็กชัน "Sushi"
        .doc(userId) // เลือกเอกสารที่มี userId ที่กำหนด
        .set(userInfoMap); // บันทึกข้อมูลซูชิใหม่
  }

  // CREATE: ฟังก์ชันสำหรับเพิ่มข้อมูลผู้ใช้ใหม่
  Future addUser(String userId, Map<String, dynamic> userInfoMap) {
    return FirebaseFirestore.instance
        .collection("Employee")   // เข้าถึงคอลเล็กชัน "Employee"
        .doc(userId)  // เลือกเอกสารที่มี userId ที่กำหนด
        .set(userInfoMap);  // บันทึกข้อมูลผู้ใช้ใหม่
  }

  // CREATE: ฟังก์ชันสำหรับเพิ่มคำสั่งซูชิใหม่
  Future addSushiOrder(Map<String, dynamic> userInfoMap, String id) {
    return FirebaseFirestore.instance
        .collection("Order")  // เข้าถึงคอลเล็กชัน "Order"
        .doc(id) // เลือกเอกสารที่มี id ที่กำหนด
        .set(userInfoMap); // บันทึกคำสั่งซูชิใหม่
  }
  // CREATE: ฟังก์ชันสำหรับเพิ่มรายละเอียดคำสั่งซูชิ
  Future addSushiOrderDetail(Map<String, dynamic> userInfoMap, String id) {
    return FirebaseFirestore.instance
        .collection("Order") // เข้าถึงคอลเล็กชัน "Order"
        .doc(id) // เลือกเอกสารที่มี id ที่กำหนด
        .collection("OrderDetail") // เข้าถึงคอลเล็กชันย่อย "OrderDetail"
        .doc()  // สร้างเอกสารใหม่
        .set(userInfoMap);  // บันทึกข้อมูลรายละเอียดคำสั่ง
  }

  // READ: ฟังก์ชันสำหรับค้นหาซูชิตามชื่อ
  getSushi(String name) async {
    return await FirebaseFirestore.instance
        .collection("Sushi")  // เข้าถึงคอลเล็กชัน "Sushi"
        .where("Name", isEqualTo: name) // ค้นหาซูชิที่มีชื่อเท่ากับ name
        .get();  // คืนค่าผลลัพธ์
  }

  // READ: ฟังก์ชันสำหรับดึงคำสั่งทั้งหมด
  Future<Stream<QuerySnapshot>> getOrder() async {
    return await FirebaseFirestore.instance
        .collection("Order") // เข้าถึงคอลเล็กชัน "Order"
        .orderBy("Date", descending: true) // เรียงลำดับคำสั่งตามวันที่
        .snapshots(); // คืนค่า Stream ของคำสั่ง
  }

  // READ: ฟังก์ชันสำหรับดึงรายละเอียดคำสั่งซูชิ
  getOrderDetail(String id) {
    return FirebaseFirestore.instance
        .collection("Order")  // เข้าถึงคอลเล็กชัน "Order"
        .doc(id) // เลือกเอกสารที่มี id ที่กำหนด
        .collection("OrderDetail")  // เข้าถึงคอลเล็กชันย่อย "OrderDetail"
        .get();  // คืนค่าผลลัพธ์ของรายละเอียดคำสั่ง
  }

  // READ: ฟังก์ชันสำหรับดึงข้อมูลซูชิทั้งหมด
  Future<QuerySnapshot<Map<String, dynamic>>> getSushiData() async {
    return await FirebaseFirestore.instance.collection("Sushi").get(); // คืนค่าผลลัพธ์ของข้อมูลซูชิ
  }

  // READ: ฟังก์ชันสำหรับดึงข้อมูลคำสั่งทั้งหมด
  Future<QuerySnapshot<Map<String, dynamic>>> getOrdertoTotal() async {
    return await FirebaseFirestore.instance.collection("Order").get();  // คืนค่าผลลัพธ์ของคำสั่งทั้งหมด
  }

  // READ: ฟังก์ชันสำหรับดึงข้อมูลรวมยอดซูชิจากคำสั่ง
  Future<QuerySnapshot<Map<String, dynamic>>> getTotalBySushi(
      String sushiName, String id) async {
    // Query เพื่อค้นหาเอกสารที่มี OrderDetail ที่มีรายการชื่อ sushiName
    return await FirebaseFirestore.instance
        .collection('Order') // เข้าถึงคอลเล็กชัน "Order"
        .doc(id)  // เลือกเอกสารที่มี id ที่กำหนด
        .collection("OrderDetail")
        .where("name", isEqualTo: sushiName)
        .get();
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Error");
    }
  }
}
