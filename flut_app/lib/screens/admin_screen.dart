import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/services/ticket_service.dart';

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔥 SERVICE SELECTOR (DYNAMIC)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('services')
                  .where('isActive', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }

                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final services = snapshot.data!.docs;

                if (services.isEmpty) {
                  return const Text("No services available");
                }

                selectedServiceId ??= services.first.id;

                return DropdownButton<String>(
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
                      selectedServiceId = value!;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            // 🔥 CALL NEXT BUTTON
            ElevatedButton(
              onPressed: () async {
                if (selectedServiceId == null) return;

                await TicketService.callNext(selectedServiceId!);
              },
              child: const Text("Call Next Ticket"),
            ),

            const SizedBox(height: 20),

            const Divider(),

            const Text(
              "Queue Overview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // 🔥 LIVE QUEUE VIEW
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('tickets')
                    .where('serviceId', isEqualTo: selectedServiceId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final tickets = snapshot.data!.docs;

                  if (tickets.isEmpty) {
                    return const Center(child: Text("No tickets"));
                  }

                  // 🔥 Sort tickets by number
                  tickets.sort((a, b) =>
                      (a['number'] as int).compareTo(b['number'] as int));

                  return ListView.builder(
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 STATUS ICON HELPER
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