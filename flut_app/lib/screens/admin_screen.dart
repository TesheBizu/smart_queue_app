import 'package:flutter/material.dart';
import '../core/services/firebase_service.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                await FirebaseService.callNext("D3pDxoX27kJErjrRU3jB");
              },
              child: const Text("Call Next Ticket"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                await FirebaseService.callNext("D3pDxoX27kJErjrRU3jB");
              },
              child: const Text("Skip Ticket"),
            ),
          ],
        ),
      ),
    );
  }
}