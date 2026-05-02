import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/services/ticket_service.dart';
import '../core/services/auth_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String? selectedServiceId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔥 SERVICE SELECTOR
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('services')
                  .where('isActive', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final services = snapshot.data!.docs;

                return DropdownButton<String>(
                  hint: const Text("Select a service"),
                  value: selectedServiceId,
                  isExpanded: true,
                  items: services.map((doc) {
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(doc['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedServiceId = value;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 15),

            // 🔥 CALL NEXT BUTTON
            ElevatedButton(
              onPressed: selectedServiceId == null
                  ? null
                  : () async {
                      await TicketService.callNext(selectedServiceId!);
                    },
              child: const Text("Call Next Ticket"),
            ),

            const SizedBox(height: 15),

            const Divider(),

            // 🔥 MAIN CONTENT
            Expanded(
              child: selectedServiceId == null
                  ? _buildWelcomeUI()
                  : _buildDashboard(),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // 🟢 WELCOME UI
  // =========================
  Widget _buildWelcomeUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.dashboard, size: 80, color: Colors.blue),
          SizedBox(height: 20),
          Text(
            "Welcome Admin 👋",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text("Select a service to manage queue"),
        ],
      ),
    );
  }

  // =========================
  // 🔵 DASHBOARD UI
  // =========================
  Widget _buildDashboard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tickets')
          .where('serviceId', isEqualTo: selectedServiceId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final tickets = snapshot.data!.docs;

        if (tickets.isEmpty) {
          return const Center(child: Text("No tickets for this service"));
        }

        // 🔥 SORT ALL TICKETS
        tickets.sort((a, b) =>
            (a['number'] as int).compareTo(b['number'] as int));

        // 🔥 FILTER GROUPS
        final waiting = tickets
            .where((t) => t['status'] == 'waiting')
            .toList();

        final inService = tickets
            .where((t) => t['status'] == 'in_service')
            .toList();

        // 🔥 SORT WAITING
        waiting.sort((a, b) =>
            (a['number'] as int).compareTo(b['number'] as int));

        // 🔥 METRICS
        final totalWaiting = waiting.length;
        final currentServing =
            inService.isNotEmpty ? inService.first : null;
        final nextTicket =
            waiting.isNotEmpty ? waiting.first : null;

        return Column(
          children: [
            // =========================
            // 📊 SUMMARY CARDS
            // =========================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                    "Waiting", totalWaiting.toString(), Icons.people),
                _buildStatCard(
                    "Serving",
                    currentServing != null
                        ? "#${currentServing['number']}"
                        : "-",
                    Icons.person),
                _buildStatCard(
                    "Next",
                    nextTicket != null
                        ? "#${nextTicket['number']}"
                        : "-",
                    Icons.skip_next),
              ],
            ),

            const SizedBox(height: 20),

            const Divider(),

            const Text(
              "Queue List",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // =========================
            // 📋 QUEUE LIST
            // =========================
            Expanded(
              child: ListView.builder(
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final t = tickets[index];

                  return Card(
                    child: ListTile(
                      title: Text("Ticket #${t['number']}"),
                      subtitle: Text("Status: ${t['status']}"),
                      trailing: _buildStatusIcon(t['status']),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // 📦 STAT CARD
  // =========================
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 3,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 5),
            Text(value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title),
          ],
        ),
      ),
    );
  }

  // =========================
  // 🎯 STATUS ICON
  // =========================
  Widget _buildStatusIcon(String status) {
    switch (status) {
      case 'waiting':
        return const Icon(Icons.access_time, color: Colors.orange);
      case 'called':
        return const Icon(Icons.notifications, color: Colors.blue);
      case 'in_service':
        return const Icon(Icons.person, color: Colors.green);
      case 'done':
        return const Icon(Icons.check_circle, color: Colors.grey);
      case 'skipped':
        return const Icon(Icons.skip_next, color: Colors.red);
      default:
        return const Icon(Icons.help);
    }
  }
}