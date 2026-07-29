import 'dart:math';

import 'package:flutter/material.dart';

class Garden extends StatefulWidget {
  const Garden({super.key});

  @override
  State<Garden> createState() => _GardenState();
}

class _GardenState extends State<Garden> {
  bool showScaffold = false;
  var dragPositionX = 00.0;
  var dragPositionY = 00.0;

  @override
  void initState() {
    super.initState();

    // Delay the scaffold appearance by 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        showScaffold = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final angleX = dragPositionX / 180 * pi;
    final angleY = dragPositionY / 180 * pi;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: [
          // Lottie Animation
          if (!showScaffold)
            Center(
              child: Image.asset(
                'assets/garden/garden_loading.gif', // Replace with your Lottie file
                width: 200,
                height: 200,
              ),
            ),

          // Fade-in Scaffold after delay
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: showScaffold ? 1.0 : 0.0,
            child: Visibility(
              visible: showScaffold,
              child: Scaffold(
                backgroundColor: Theme.of(context).primaryColor,
                appBar: AppBar(
                  title: const Text("Garden"),
                  backgroundColor: Colors.green,
                ),
                body: Center(
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateX(angleY)
                      ..rotateY(angleX),
                    alignment: FractionalOffset.center,
                    child: GestureDetector(
                      // onHorizontalDragUpdate: (details) {
                      //   setState(() {
                      //     dragPositionX -= details.delta.dx;
                      //     dragPositionX %= 360;
                      //   });
                      // },
                      onVerticalDragUpdate: (details) {
                        setState(() {
                          if (dragPositionY > -70 && dragPositionY < 0) {
                            dragPositionY += details.delta.dy;
                          }
                          print(dragPositionY);
                          dragPositionX %= 360;
                        });
                      },
                      child: Container(
                        height: 330,
                        width: 330,
                        decoration: const BoxDecoration(
                            color: Colors.green,
                            border: Border(
                                top: BorderSide(color: Colors.black),
                                bottom: BorderSide(color: Colors.red))),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
