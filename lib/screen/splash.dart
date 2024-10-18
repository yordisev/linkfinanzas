import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:codigoqr/menu.dart';
import 'package:flutter/material.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.green.shade400,
      body: AnimatedContainer(
        duration: const Duration(seconds: 1),
        color: Colors.green.shade400,
        child: FutureBuilder(
          future: scren(context),
          builder: (context, snapshot) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ZoomIn(
                delay: const Duration(milliseconds: 500),
                duration: const Duration(milliseconds: 1000),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 50),
                      child: Column(
                        children: [
                          FadeInDown(
                            animate: true,
                            delay: const Duration(milliseconds: 1200),
                            duration: const Duration(milliseconds: 1000),
                            child: Icon(Icons.security_outlined,
                                color: Colors.white, size: 150),
                          ),
                          SizedBox(height: 20),
                          FadeInUp(
                            animate: true,
                            delay: const Duration(milliseconds: 1200),
                            duration: const Duration(milliseconds: 1000),
                            child: Text(
                              textAlign: TextAlign.center,
                              'Claves Finanzas y Mass.....',
                              style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
              ),
            );
          },
        ),
      ),
    );
  }
}

Future scren(BuildContext context) async {
  if (context != null && context.mounted) {
    await Future.delayed(
      const Duration(seconds: 6),
      () {
        if (context.mounted) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => MenuScreen()));
        }
      },
    );
  }
}
