import 'package:blood_test_repo/api_service.dart';
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
    try {
      final response = await ApiService.getReports(2);
      // Process the successful response (e.g., parse JSON data)
      print(response.data);
    } on Exception catch (e) {
      print('Error: ${e.toString()}');
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
