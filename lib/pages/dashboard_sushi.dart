import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d_chart/d_chart.dart';

import 'package:flutter/material.dart';
import 'package:projectjobb/service/database.dart';

class Dashboard_Sushi extends StatefulWidget {
  const Dashboard_Sushi({super.key});

  @override
  State<Dashboard_Sushi> createState() => _Dashboard_SushiState();
}

class _Dashboard_SushiState extends State<Dashboard_Sushi> {
  // Stream สำหรับดึงข้อมูลจาก Firestore คอลเลคชัน 'Sushi'
  final Stream<QuerySnapshot> sushiStream =
  FirebaseFirestore.instance.collection('Sushi').snapshots();

  double totalAmount = 0.0; // ตัวแปรสำหรับเก็บยอดรวมทั้งหมด

  @override
  void initState() {
    super.initState(); // เรียก initState เพื่อเตรียมค่าต่าง ๆ ก่อนใช้งาน
  }

  Future<List<OrdinalData>> _fetchChartData() async {
    List<OrdinalData> chartData = [];

    try {
      // ดึงข้อมูล Sushi ทั้งหมดครั้งเดียว
      final sushiSnapshot = await DatabaseMethods().getSushiData();

      // ใช้ Future.wait เพื่อรันทุก Query พร้อมกัน
      final futures = sushiSnapshot.docs.map((sushiDoc) async {
        String sushiName = sushiDoc['Name'] ?? 'Unknown';
        double totalAmount = 0.0;

        // ดึงข้อมูล Order ทั้งหมดครั้งเดียว
        final orderSnapshot = await DatabaseMethods().getOrdertoTotal();

        // ใช้ Future.wait สำหรับการดึง total ของ Sushi ในแต่ละ Order
        final orderTotals =
        await Future.wait(orderSnapshot.docs.map((orderDoc) async {
          final querySnapshot = await DatabaseMethods()
              .getTotalBySushi(sushiName, orderDoc["Id"]);

          return querySnapshot.docs.fold<double>(
            0.0,
                (sum, doc) => sum + doc['total'].toDouble(),
          );
        }));

        // รวมยอดขายทั้งหมด
        totalAmount = orderTotals.fold(0.0, (sum, total) => sum + total);

        return OrdinalData(domain: sushiName, measure: totalAmount);
      });

      // รอให้ Future ทั้งหมดเสร็จ
      chartData = await Future.wait(futures);
    } catch (e) {
      print("Error fetching chart data: $e");
    }

    return chartData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('สรุปยอดขายซูชิ')),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<OrdinalData>>(
          future: _fetchChartData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error loading chart data'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No data available'));
            }

            List<OrdinalData> chartData = snapshot.data!;

            return SingleChildScrollView(
              // Wrap the entire content
              child: Column(
                children: [
                  SizedBox(
                    child: AspectRatio(
                      aspectRatio: 16 / 9, // Adjust width-to-height ratio
                      child: DChartPieO(
                        data: chartData,
                        customLabel: (chartData, index) {
                          return '${chartData.domain}: ${chartData.measure.toStringAsFixed(0)} บาท';
                        },
                        configRenderPie: ConfigRenderPie(
                          arcLabelDecorator: ArcLabelDecorator(
                            labelPosition: ArcLabelPosition.outside,
                            leaderLineStyle: const ArcLabelLeaderLineStyle(
                              color: Colors.black87,
                              length: 30,
                              thickness: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'ยอดขาย Sushi รายการต่าง ๆ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
