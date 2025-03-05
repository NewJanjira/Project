import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:camera/camera.dart';

import 'package:projectjobb/service/database.dart';
import 'package:random_string/random_string.dart';


import 'package:projectjobb/user.dart';

late List<CameraDescription> camerass; // รายการกล้องที่เชื่อมต่อ
late int countTuna = 0; // ตัวแปรเก็บจำนวนทูน่าที่ตรวจจับ
late int countSalmon = 0; // ตัวแปรเก็บจำนวนแซลมอนที่ตรวจจับ
late int countSeaweedsalad = 0; // ตัวแปรเก็บจำนวนยำสาหร่ายที่ตรวจจับ
late int countSquid = 0; // ตัวแปรเก็บจำนวนปลาหมึกที่ตรวจจับ
late int countSweeteggs = 0; // ตัวแปรเก็บจำนวนไข่หวานที่ตรวจจับ
late double total = 0; // ตัวแปรเก็บยอดรวมราคา

// StatelessWidget สำหรับหน้าจอที่แสดงผลการตรวจจับวัตถุจาก YOLO
class YoloVideo extends StatefulWidget {
  const YoloVideo({Key? key}) : super(key: key);

  @override
  State<YoloVideo> createState() => _YoloVideoState();
}

// State สำหรับหน้าจอ YoloVideo
class _YoloVideoState extends State<YoloVideo> {
  late CameraController controller; // ตัวควบคุมการใช้งานกล้อง
  late FlutterVision vision;  // ตัวแปรสำหรับการใช้งาน YOLO Model
  late List<Map<String, dynamic>> yoloResults; // รายการผลการตรวจจับจาก YOLO
  late List<Map<String, dynamic>> sushi; // รายการข้อมูลซูชิที่ถูกตรวจจับ

  CameraImage? cameraImage; // ตัวแปรเก็บข้อมูลภาพจากกล้อง
  bool isLoaded = false; // ตัวแปรบ่งชี้ว่าโมเดล YOLO โหลดเสร็จแล้วหรือยัง
  bool isDetecting = false; // ตัวแปรบ่งชี้ว่ากำลังตรวจจับหรือไม่
  @override
  void initState() {
    super.initState();
    init(); // เรียกใช้ฟังก์ชัน init ในการเริ่มต้น
  }

  // ฟังก์ชันเริ่มต้นในการตั้งค่ากล้องและโหลด YOLO Model
  init() async {
    camerass = await availableCameras(); // ดึงข้อมูลกล้องทั้งหมด
    vision = FlutterVision(); // สร้างอินสแตนซ์ของ FlutterVision
    controller = CameraController(camerass[0], ResolutionPreset.high); // ตั้งค่ากล้องให้ใช้กล้องตัวแรกและความละเอียดสูง

    await controller.initialize(); // เริ่มต้นการใช้งานกล้อง
    await loadYoloModel(); // โหลด YOLO Model
    setState(() {
      isLoaded = true; // เมื่อโหลดเสร็จแล้วให้เปลี่ยนสถานะ
      yoloResults = []; // รีเซ็ตผลการตรวจจับ
      sushi = []; // รีเซ็ตรายการซูชิ
    });
    await startDetection();  // เริ่มการตรวจจับวัตถุ
  }

  // ฟังก์ชันปลดการใช้งานเมื่อหน้าจอถูกทิ้ง
  @override
  void dispose() async {
    super.dispose();
    controller.dispose(); // ปลดการใช้งานกล้อง
    await vision.closeYoloModel(); // ปิดโมเดล YOLO
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    if (!isLoaded) {
      return const Scaffold(
        body: Center(
          child: Text("Model not loaded, waiting for it"),
        ),
      );
    }
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: CameraPreview(
              controller,
            ),
          ),
          ...displayBoxesAroundRecognizedObjects(size), // แสดงกล่องรอบวัตถุที่ตรวจจับได้
          Positioned(
            bottom: 75,
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ปุ่มถ่ายภาพ
                ElevatedButton(
                  onPressed: takePicture,
                  child: const Icon(Icons.camera_alt),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// ฟังก์ชันโหลดโมเดล YOLO
  Future<void> loadYoloModel() async {
    await vision.loadYoloModel(
        labels: 'assets/classes.txt', // รายการป้าย (labels)
        modelPath: 'assets/yolov8_custom_bn.tflite', // ที่อยู่ของโมเดล
        modelVersion: "yolov8",  // เวอร์ชันของโมเดล
        numThreads: 2, // จำนวนเธรดที่ใช้ในการประมวลผล
        useGpu: true); // ใช้ GPU ในการประมวลผล
    setState(() {
      isLoaded = true; // เปลี่ยนสถานะเมื่อโมเดลโหลดเสร็จ
    });
  }

 // ฟังก์ชันการตรวจจับวัตถุในภาพที่ถูกส่งมาจากกล้อง
  Future<void> yoloOnFrame(CameraImage cameraImage) async {
    final result = await vision.yoloOnFrame(
        bytesList: cameraImage.planes.map((plane) => plane.bytes).toList(),
        imageHeight: cameraImage.height,
        imageWidth: cameraImage.width,
        iouThreshold: 0.4, // ค่าความแม่นยำที่ยอมรับได้
        confThreshold: 0.4,  // ค่าความมั่นใจในการตรวจจับ
        classThreshold: 0.5); // ค่าความมั่นใจในการตรวจจับประเภทวัตถุ
    if (result.isNotEmpty) {
      setState(() {
        yoloResults = result; // อัปเดตผลการตรวจจับ
      });
    }
  }

  // ฟังก์ชันเริ่มการตรวจจับภาพจากกล้อง
  Future<void> startDetection() async {
    if (controller.value.isStreamingImages) {
      return;
    }
    await controller.startImageStream((image) async {
      cameraImage = image; // เก็บข้อมูลภาพจากกล้อง
      yoloOnFrame(image);  // เรียกใช้การตรวจจับบนภาพ
    });
  }

  // ฟังก์ชันแสดงกล่องรอบวัตถุที่ตรวจจับได้
  List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
    if (yoloResults.isEmpty) return [];
    double factorX = screen.width / (cameraImage?.height ?? 1);
    double factorY = screen.height / (cameraImage?.width ?? 1);

    Color colorPick = const Color.fromARGB(255, 50, 233, 30);

    return yoloResults.map((result) {
      double objectX = result["box"][0] * factorX;
      double objectY = result["box"][1] * factorY;
      double objectWidth = (result["box"][2] - result["box"][0]) * factorX;
      double objectHeight = (result["box"][3] - result["box"][1]) * factorY;

      return Positioned(
        left: objectX,
        top: objectY,
        width: objectWidth,
        height: objectHeight,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(color: Colors.black, width: 2.0),
          ),
          child: Text(
            "${result['tag']} ${(result['box'][4] * 100).toStringAsFixed(0)}%", // แสดงชื่อประเภทวัตถุและเปอร์เซ็นต์ความมั่นใจ
            style: TextStyle(
              background: Paint()..color = colorPick,
              color: const Color.fromARGB(255, 115, 0, 255),
              fontSize: 18.0,
            ),
          ),
        ),
      );
    }).toList();
  }

  // ฟังก์ชันถ่ายภาพและสรุปผลการตรวจจับ
  Future<void> takePicture() async {
    if (!controller.value.isInitialized) {
      return;
    }

    try {
      // ถ่ายภาพ
      final XFile picture = await controller.takePicture(); // ถ่ายภาพ
      // สรุปผลตรวจจับทั้งหมด
      for (var result in yoloResults) {
        String tag = result['tag'];
        switch (tag) {
          case "tuna":
            countTuna++; // เพิ่มจำนวนทูน่า
            QuerySnapshot priceSnapshot = await FirebaseFirestore.instance
                .collection("Sushi")
                .where("Name", isEqualTo: "ทูน่า") // ดึงข้อมูลราคาทูน่า
                .get();
            if (priceSnapshot.docs.isEmpty) {
              print('No sushi found with name: ทูน่า');
            }
            DocumentSnapshot doc = priceSnapshot.docs.first;
            Map<String, dynamic> price = doc.data() as Map<String, dynamic>;

            final index = sushi.indexWhere((item) => item['name'] == "ทูน่า");
            print(index);
            if (index == -1) {
              // หากยังไม่มีข้อมูลซูชิประเภทนี้ในรายการ
              sushi.add({
                'name': "ทูน่า",
                'quantity': countTuna,
                'price': price['Price'],
                'total': countTuna * price['Price'],
              });
            } else {
              // หากมีข้อมูลแล้วให้ปรับปรุงข้อมูล
              sushi[index]['quantity'] = countTuna;
              sushi[index]['total'] = countTuna * sushi[index]['price'];
            }
            //_updateSushiData("ทูน่า", countTuna);
            break;
        // เพิ่มเคสอื่นๆ ตามประเภทวัตถุที่ตรวจจับ เช่น salmon, seaweedsalad เป็นต้น
          case "salmon":
            countSalmon++;
            QuerySnapshot priceSnapshot = await FirebaseFirestore.instance
                .collection("Sushi")
                .where("Name", isEqualTo: "แซลมอน")
                .get();
            if (priceSnapshot.docs.isEmpty) {
              print('No sushi found with name: แซลมอน');
            }
            DocumentSnapshot doc = priceSnapshot.docs.first;
            Map<String, dynamic> price = doc.data() as Map<String, dynamic>;

            final index = sushi.indexWhere((item) => item['name'] == "แซลมอน");
            print(index);
            if (index == -1) {
              // Add new item
              sushi.add({
                'name': "แซลมอน",
                'quantity': countSalmon,
                'price': price['Price'],
                'total': countSalmon * price['Price'],
              });
            } else {
              // Update existing item
              sushi[index]['quantity'] = countSalmon;
              sushi[index]['total'] = countSalmon * sushi[index]['price'];
            }
            // _updateSushiData("แซลมอน", countSalmon);
            break;
          case "seaweedsalad":
            countSeaweedsalad++;
            QuerySnapshot priceSnapshot = await FirebaseFirestore.instance
                .collection("Sushi")
                .where("Name", isEqualTo: "ยำสาหร่าย")
                .get();
            if (priceSnapshot.docs.isEmpty) {
              print('No sushi found with name: ยำสาหร่าย');
            }
            DocumentSnapshot doc = priceSnapshot.docs.first;
            Map<String, dynamic> price = doc.data() as Map<String, dynamic>;

            final index =
                sushi.indexWhere((item) => item['name'] == "ยำสาหร่าย");
            print(index);
            if (index == -1) {
              // Add new item
              sushi.add({
                'name': "ยำสาหร่าย",
                'quantity': countSeaweedsalad,
                'price': price['Price'],
                'total': countSeaweedsalad * price['Price'],
              });
            } else {
              // Update existing item
              sushi[index]['quantity'] = countSeaweedsalad;
              sushi[index]['total'] = countSeaweedsalad * sushi[index]['price'];
            }
            //_updateSushiData("ยำสาหร่าย", countSeaweedsalad);
            break;
          case "squid":
            countSquid++;
            QuerySnapshot priceSnapshot = await FirebaseFirestore.instance
                .collection("Sushi")
                .where("Name", isEqualTo: "ปลาหมึก")
                .get();
            if (priceSnapshot.docs.isEmpty) {
              print('No sushi found with name: ปลาหมึก');
            }
            DocumentSnapshot doc = priceSnapshot.docs.first;
            Map<String, dynamic> price = doc.data() as Map<String, dynamic>;

            final index = sushi.indexWhere((item) => item['name'] == "ปลาหมึก");
            print(index);
            if (index == -1) {
              // Add new item
              sushi.add({
                'name': "ปลาหมึก",
                'quantity': countSquid,
                'price': price['Price'],
                'total': countSquid * price['Price'],
              });
            } else {
              // Update existing item
              sushi[index]['quantity'] = countSquid;
              sushi[index]['total'] = countSquid * sushi[index]['price'];
            }
            //_updateSushiData("ปลาหมึก", countSquid);
            break;
          case "sweeteggs":
            countSweeteggs++;
            QuerySnapshot priceSnapshot = await FirebaseFirestore.instance
                .collection("Sushi")
                .where("Name", isEqualTo: "ไข่หวาน")
                .get();
            if (priceSnapshot.docs.isEmpty) {
              print('No sushi found with name: ไข่หวาน');
            }
            DocumentSnapshot doc = priceSnapshot.docs.first;
            Map<String, dynamic> price = doc.data() as Map<String, dynamic>;

            final index = sushi.indexWhere((item) => item['name'] == "ไข่หวาน");
            print(index);
            if (index == -1) {
              // Add new item
              sushi.add({
                'name': "ไข่หวาน",
                'quantity': countSweeteggs,
                'price': price['Price'],
                'total': countSweeteggs * price['Price'],
              });
            } else {
              // Update existing item
              sushi[index]['quantity'] = countSweeteggs;
              sushi[index]['total'] = countSweeteggs * sushi[index]['price'];
            }
            //_updateSushiData("ไข่หวาน", countSweeteggs);
            break;
        }
        print(sushi);  // แสดงข้อมูลซูชิที่ตรวจจับ
      }
      print(sushi);

      // คำนวณยอดรวมทั้งหมด
      for (var data in sushi) {
        total = total + data["total"];
      }

      // ไปยังหน้าจอแสดงภาพที่ถ่าย
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(
            sushiData: sushi,
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error taking picture: $e"); // แสดงข้อผิดพลาดถ้ามี
    }
  }

  // ฟังก์ชัน main เริ่มต้นแอปพลิเคชัน
  main() async {
    WidgetsFlutterBinding.ensureInitialized();

    runApp(
      const MaterialApp(
        home: YoloVideo(), // เริ่มต้นที่หน้าจอ YoloVideo
      ),
    );
  }

// Here we start writing our code.
}

class DisplayPictureScreen extends StatelessWidget {
  final List<Map<String, dynamic>>? sushiData; // รายการข้อมูลซูชิ


  const DisplayPictureScreen({
    super.key,
    required this.sushiData,
    //required this.detectionInfo,
  });

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('ตรวจสอบผลลัพท์'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // รีเซ็ตค่าตัวแปรต่าง ๆ เมื่อกดปุ่มย้อนกลับ
              countSquid = 0;
              countSeaweedsalad = 0;
              countTuna = 0;
              countSalmon = 0;
              countSweeteggs = 0;
              total = 0;
              sushiData!.clear(); // ล้างข้อมูลซูชิที่บันทึกไว้
              Navigator.pop(
                context,
                MaterialPageRoute(builder: (context) => const YoloVideo()),
              );
              // กลับไปหน้า YoloVideo
            },
          ),
        ),
        body: SafeArea(
          child: SizedBox.expand(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                  columns: _createColumn(), rows: _createRow(sushiData)),
            ),
          ),
        ),
        bottomSheet:
            Text("ยอดรวม : " + total.toString(), textAlign: TextAlign.right), // แสดงยอดรวมที่ด้านล่างของหน้าจอ
        floatingActionButton: ElevatedButton(
            child: Text('ยืนยันการสั่งซื้อ'),
            onPressed: () async {
              String Id = randomAlphaNumeric(20);
              final now = new DateTime.now(); // วันที่และเวลาปัจจุบัน

              // สร้างข้อมูลออเดอร์ซูชิ
              Map<String, dynamic> sushiOrder = {
                "Id": Id,
                "Date": now,
                "Employee": FirebaseAuth.instance.currentUser!.uid,
                "TotalAmount": total,
              };

              // เพิ่มข้อมูลออเดอร์ลงในฐานข้อมูล
              await DatabaseMethods()
                  .addSushiOrder(sushiOrder, Id)
                  .then((value) async { // วนลูปเพิ่มข้อมูลรายละเอียดของแต่ละซูชิที่สั่ง
                    for (var data in sushiData!) {
                  Map<String, dynamic> sushiOrderDetails = {
                    "name": data['name'],  // ชื่อซูชิ
                    "price": data['price'], // ราคาต่อชิ้น
                    "quantity": data['quantity'], // จำนวนที่สั่ง
                    "total": data['total'],  // ราคาทั้งหมดของซูชินั้น
                  };
                  DatabaseMethods().addSushiOrderDetail(sushiOrderDetails, Id);
                }

                // แสดงข้อความแจ้งเตือนว่าการสั่งซื้อสำเร็จ
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                  "Add order Successfully",
                  style: TextStyle(fontSize: 20.0),
                )));
                ;
                // นำทางไปยังหน้าหลัก
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyHomePages()));
              });
            }
            ));
  }
  // ฟังก์ชันสร้างคอลัมน์ของตาราง
  List<DataColumn> _createColumn() {
    return [
      DataColumn(
        label: Text("ประเภทซูชิ"),
      ),
      DataColumn(
        label: Text("จำนวน"),
      ),
      DataColumn(
        label: Text("ราคา"),
      ),
      DataColumn(
        label: Text("ราคารวม"),
      ),
    ];
  }

  // ฟังก์ชันสร้างแถวของตารางจากข้อมูลซูชิ
  List<DataRow> _createRow(List<Map<String, dynamic>>? sushi) {
    return sushi!.map((data) {
      return DataRow(cells: [
        DataCell(
          Text(data['name']),
        ),
        DataCell(
          Text(data['quantity'].toString()),
        ),
        DataCell(
          Text(data['price'].toString()),
        ),
        DataCell(
          Text(data['total'].toString()),
        ),
      ]);
    }).toList();
  }
}
