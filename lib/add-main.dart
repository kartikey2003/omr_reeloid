import 'package:flutter/material.dart';

import 'adds-skip.dart';
import 'homepage.dart';

class AddMain extends StatefulWidget {
  const AddMain({super.key});

  @override
  State<AddMain> createState() => _AddMainState();
}

class _AddMainState extends State<AddMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => VideoAdsSequence()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Container(
                color: Colors.blue,
                height: 100,
                width: 120,
                child: Center(child: Text("Adss-with-Skip")),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
