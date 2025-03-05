import 'package:flutter/material.dart';
import 'package:projectjobb/pages/dashboard_sushi.dart';

import 'package:projectjobb/pages/dashboard_order.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('สรุปยอดขาย')),
        backgroundColor: Colors.white,
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          SizedBox(height: 20.0), // เพิ่มระยะห่างด้านบน 20.0

           ElevatedButton(
             style: ElevatedButton.styleFrom(
               minimumSize: Size(200, 50), // ขยายขนาดปุ่ม (กว้าง x สูง)
             ),
            child: Text('ยอดขายซูชิ'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Dashboard_Sushi()),
            ),
          ),
          SizedBox(height: 10.0),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(200, 50), // ขยายขนาดปุ่ม (กว้าง x สูง)
            ),
            child: Text('สรุปยอดขายตามคำสั่งซื้อ'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrderChartPage()),
            ),
          ),
        ])));
  }
}
