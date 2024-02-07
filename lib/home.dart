import 'dart:ffi';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:dashboard_1/navigator/gnav.dart';
import 'package:flutter/material.dart';

// import 'base.dart';
import 'login_page/login_register_page.dart';
import 'login_page/auth.dart';

class home extends StatelessWidget {
  const home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: Auth().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // todo();
            return const gnav();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}

// Map<String, dynamic> generateRandomData() {
//   Random random = Random();

//   int randomPH = random.nextInt(7) + 4; // Range: 4 to 10
//   double randomDO = double.parse((2.0 + random.nextDouble() * 4.0)
//       .toStringAsFixed(2)); // Range: 2.0 to 6.0
//   double randomTEMP = double.parse((20.0 + random.nextDouble() * 40.0)
//       .toStringAsFixed(2)); // Range: 20.0 to 40.0
//   int randomTDS = random.nextInt(26) + 5; // Range: 5 to 30

//   Map<String, dynamic> randomData = {
//     'PH': randomPH,
//     'DO': randomDO,
//     'TEMP': randomTEMP,
//     'TDS': randomTDS,
//   };

//   return randomData;
// }

// void todo() {
//   FirebaseFirestore firestore = FirebaseFirestore.instance;

//   final DateFormat dateFormat = DateFormat('yyyy:MM:dd HH:mm:ss');
//   DateTime startDate = DateTime(2023, 3, 20, 3, 21, 7);
//   DateTime currentDate = DateTime(2023, 4, 17, 3, 21, 7);
//   int hoursInterval = 2;
//   int minutes = 48;
//   int seconds = 30;
//   List db = [];

//   while (startDate.isBefore(currentDate)) {
//     String formattedDate = dateFormat.format(startDate);
//     Map<String, dynamic> randomData = generateRandomData();
//     // firestore
//     //     .collection('dataStore')
//     //     .doc(Auth().currentUser!.email)
//     //     .collection("pond1")
//     //     .doc("system1")
//     //     .set({formattedDate: randomData}, SetOptions(merge: true));
//     db.add({formattedDate: randomData});
//     startDate = startDate.add(
//         Duration(hours: hoursInterval, minutes: minutes, seconds: seconds));
//   }
//   print(db.length);
// }
