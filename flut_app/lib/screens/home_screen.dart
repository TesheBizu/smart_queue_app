import 'package:flutter/material.dart';
import 'provider_screen.dart';
import 'admin_screen.dart';
import 'user_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Queue"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          "Welcome to Smart Queue",
          style: TextStyle(fontSize: 18),
        ),
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const UserScreen(),
      ),
    ); 
  },
  child: const Text("Get Ticket (User)"),
),
          FloatingActionButton(
            heroTag: "admin",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminScreen(),
                ),
              );
            },
            child: const Icon(Icons.admin_panel_settings),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "provider",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProviderScreen(),
                ),
              );
            },
            child: const Icon(Icons.medical_services),
          ),
        ],
      ),
    );
  }
}