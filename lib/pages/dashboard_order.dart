import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d_chart/d_chart.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "สรุปยอดขายตามคำสั่งซื้อ",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const OrderChartPage(),
    );
  }
}

// StatefulWidget สำหรับหน้าสรุปยอดขายตามคำสั่งซื้อ
class OrderChartPage extends StatefulWidget {
  const OrderChartPage({Key? key}) : super(key: key);

  @override
  _OrderChartPageState createState() => _OrderChartPageState();
}

class _OrderChartPageState extends State<OrderChartPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false; // ตัวแปรแสดงสถานะการโหลดข้อมูล
  List<Map<String, dynamic>> _filteredOrders = []; // เก็บรายการที่กรองแล้ว

  // ฟังก์ชันเลือกวันที่
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2000), // กำหนดวันที่เริ่มต้นต่ำสุด
      lastDate: DateTime(2100), // กำหนดวันที่สิ้นสุดสูงสุด
      helpText: isStartDate ? 'ระบุวันที่เริ่มต้น' : 'ระบุวันที่สิ้นสุด',
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          print(_startDate);
        } else {
          _endDate = picked;
          print(_endDate);
        }
      });
    }
  }

  // ดึงข้อมูลจาก Firestore และจำกัดให้แสดงแค่ 7 วันล่าสุด
  Future<void> _fetchOrders() async {
    // ตรวจสอบวันที่เริ่มต้นและสิ้นสุด
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('โปรดระบุวันที่เริ่มต้น - สิ้นสุดก่อน')),
      );
      return;
    }
    if (_startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('วันที่เริ่มต้นห้ามมากกว่าวันที่สิ้นสุด')),
      );
      return;
    }
    setState(() {
      _isLoading = true; // ตั้งสถานะกำลังโหลด
    });

    try {
      // ปรับเวลาวันที่เริ่มต้นและสิ้นสุด
      final startDateAdjusted =
          _startDate!.toUtc().add(const Duration(hours: 7));
      final endDateAdjusted = _endDate!.toUtc().add(const Duration(hours: 7));

      // Query ข้อมูลจาก Firestore
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Order')
          .where('Date', isGreaterThanOrEqualTo: startDateAdjusted)
          .where('Date', isLessThanOrEqualTo: endDateAdjusted)
          .orderBy('Date')
          .get();

      // จัดรูปแบบข้อมูล
      final orders = querySnapshot.docs.map((doc) {
        return {
          'Date': doc['Date'],
          'TotalAmount': doc['TotalAmount'],
        };
      }).toList();

      setState(() {
        _filteredOrders = orders;  // อัปเดตรายการคำสั่งซื้อ
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching orders: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // ยกเลิกสถานะกำลังโหลด
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // เตรียมข้อมูลสำหรับ DChartBarO
    List<OrdinalData> chartData = _filteredOrders.map((order) {
      return OrdinalData(
        domain: DateFormat('dd/MM/yyyy')
            .format(order['Date'].toDate())
            .toString(), // Domain = วันที่
        measure: order['TotalAmount'], // Measure = ยอดรวม
      );
    }).toList();

    // กำหนดกลุ่มข้อมูลสำหรับกราฟ
    final groupList = [
      OrdinalGroup(
        id: 'Order',
        data: chartData, // ใช้ข้อมูล chartData ที่เป็น List<OrdinalData>
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('สรุปยอดขายตามคำสั่งซื้อ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _selectDate(context, true),
                  child: Text(_startDate == null
                      ? 'เลือกวันที่เริ่มต้น'
                      : 'เริ่มต้น: ${DateFormat('dd/MM/yyyy').format(_startDate!)}'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _selectDate(context, false),
                  child: Text(_endDate == null
                      ? 'เลือกวันที่สิ้นสุด'
                      : 'สิ้นสุด: ${DateFormat('dd/MM/yyyy').format(_endDate!)}'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchOrders,
              child: const Text('ยืนยัน'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: DChartBarO(
                      groupList:
                          groupList, // ส่งข้อมูล groupList ที่ประกอบไปด้วย OrdinalGroup
                    ),
                  ),
            if (!_isLoading && _filteredOrders.isEmpty)
              const Text(
                'ไม่มีการสั่งซื้ออยู่ในช่วงเวลานี้',
                style: TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
