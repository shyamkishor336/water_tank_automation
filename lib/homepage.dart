import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{
  final databaseRef = FirebaseDatabase.instance.ref();
  final Future<FirebaseApp> _future = Firebase.initializeApp();

  @override
  void initState() {
    // TODO: implement initState
    getWifiStatus();
    super.initState();
  }

  void addData(String key, String data) {
    Map<String, Object?> updates = {};
    updates[key] = data;
    databaseRef.update(updates);
  }

  // void printFirebase(){
  //   databaseRef.once().then((DataSnapshot snapshot) {
  //     print('Data : ${snapshot.value}');
  //   });
  // }
  String motor_status = "";
  double tank_status = 0;
  double reservoir_status = 0;

  static const _backgroundColor = Colors.white;

  static const _colors = [
    Color(0xFFFEE440),
    Color(0xFF00BBF9),
  ];

  static const _durations = [
    5000,
    4000,
  ];
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  void getWifiStatus() async {
    addData("Wifi_Status", "Hello");
    await Future.delayed(Duration(milliseconds: 2000));
    final snapshot = await ref.child('Wifi_Status').get();
    if (snapshot.value.toString() == "Hi") {
      wifiStatus = true;
    } else {
      wifiStatus = false;
    }

    setState(() {});
  }

  static const _heightPercentages = [
    0.0,
    0.01,
  ];
  bool wifiStatus = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Water Tank Automation"),
      ),
      body: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            } else {
              DatabaseReference statusRef =
                  FirebaseDatabase.instance.ref('Motor_Status');
              DatabaseReference tankRef =
                  FirebaseDatabase.instance.ref('Tank_Status');
              DatabaseReference reservoirRef =
                  FirebaseDatabase.instance.ref('Reservoir_Status');
              statusRef.onValue.listen((DatabaseEvent event) async{
                final data = event.snapshot.value;
                motor_status = data.toString();
                final snapshot = await ref.child('Wifi_Status').get();
                if (snapshot.value.toString() == "Hi") {
                  wifiStatus = true;
                } else {
                  wifiStatus = false;
                }
                setState(() {});
              });
              tankRef.onValue.listen((DatabaseEvent event) {
                final data = event.snapshot.value;
                tank_status = double.parse(
                    double.parse(data.toString()).toStringAsFixed(1));
                if(tank_status<0)
                  tank_status = 0;
                else if(tank_status>100)
                  tank_status=100;
                setState(() {});
              });
              reservoirRef.onValue.listen((DatabaseEvent event) {
                final data = event.snapshot.value;
                reservoir_status = double.parse(
                    double.parse(data.toString()).toStringAsFixed(1));
                if(reservoir_status<0)
                  reservoir_status = 0;
                else if(reservoir_status>100)
                  reservoir_status=100;
                setState(() {});
              });
              return Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 50,),
                        Text(
                          wifiStatus
                              ? "Device Connected"
                              : "Device Not Connected",
                          style: TextStyle(
                              color: wifiStatus ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(width: 50,),
                        InkWell(
                          onTap: getWifiStatus,
                          child: Icon(
                            Icons.refresh,
                            size: 32,
                          ),
                        ),
                      ],
                    ),

                    Text(
                      "Motor Status: " + motor_status,
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Tank Status:  $tank_status % Filled",
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Reservoir Status: $reservoir_status % Filled",
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(
                      height: 60,
                    ),
                    // AnimationFlow(),
                    Stack(
                      children: [
                        Container(
                          height: 350,
                          width: 300,
                          // margin: EdgeInsets.only(left: 30),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(25),
                                  bottomRight: Radius.circular(25)),
                              border:
                                  Border.all(width: 2, color: Colors.black)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(25),
                                bottomRight: Radius.circular(25)),
                            child: WaveWidget(
                              config: CustomConfig(
                                colors: _colors,
                                durations: _durations,
                                heightPercentages: [
                                  (90 - tank_status) / 100,
                                  (91 - tank_status) / 100,
                                ],
                              ),
                              backgroundColor: _backgroundColor,
                              size: Size(300, 350),
                              waveAmplitude: 0,
                            ),
                          ),
                        ),
                        Positioned(
                            top: 100,
                            left: 120,
                            child: Center(
                              child: Text(
                                "Water \nTank\n\n$tank_status%",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500),
                              ),
                            ))
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),

                  ],
                ),
              );
            }
          }),
    );
  }
}



// if(wifiStatus)
// InkWell(
//   onTap: () {
//     if (reservoir_status < 10) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Row(
//           children: [
//             Icon(
//               Icons.warning_amber,
//               color: Colors.red,
//             ),
//             const Text(
//               '  Reservoir tank has not suffient water...',
//               style: TextStyle(color: Colors.white),
//             ),
//           ],
//         ),
//       ));
//     } else {
//       if (motor_status == "OFF")
//         motor_status = "ON";
//       else if (motor_status == "ON") motor_status = "OFF";
//       setState(() {
//         addData("Motor_Status", motor_status);
//       });
//     }
//   },
//   child: Container(
//     margin: EdgeInsets.only(top: 16),
//     padding: EdgeInsets.all(16),
//     child: Text(
//       "Switch ${motor_status == "ON" ? "OFF" : "ON"} Motor",
//       style: TextStyle(color: Colors.white),
//     ),
//     decoration: BoxDecoration(
//         color: Colors.black,
//         borderRadius: BorderRadius.circular(12)),
//   ),
// )
