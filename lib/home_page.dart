import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    getReports();
    super.initState();
  }

  void getReports() async {
    Dio dio = Dio();
    String url = 'https://my-kaizen-backend.onrender.com/api/getReports';
    Map<String, dynamic> requestData = {
      "userId": 2,
    };
    try {
      Response response = await dio.post(
        url,
        data: requestData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        print('Response data: ${response.data}');
      } else {
        print('Error: ${response.statusCode} - ${response.statusMessage}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Bood report"),
            SizedBox(
              height: 50,
            ),
            Text("add graph code here"),
          ],
        ),
      ),
    );
  }
}
