import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderScreen extends StatefulWidget {
  const ProviderScreen({super.key});

  @override
  State<ProviderScreen> createState() => _ProviderScreenState();
}

class _ProviderScreenState extends State<ProviderScreen> {
  String? selectedServiceId;
  final String providerId = "provider1";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Provider Dashboard")),
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
                  hint: const Text("Select your service"),
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

            const SizedBox(height: 20),

            Expanded(
              child: selectedServiceId == null
                  ? _buildWelcome()
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
  Widget _buildWelcome() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.person, size: 80, color: Colors.green),
          SizedBox(height: 20),
          Text(
            "Welcome Provider 👋",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text("Select a service to begin"),
        ],
      ),
    );
  }

  // =========================
  // 🔵 DASHBOARD
  // =========================
  Widget _buildDashboard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tickets')
          .where('serviceId', isEqualTo: selectedServiceId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final tickets = snapshot.data!.docs;

        // 🔥 FILTER
        final waiting =
            tickets.where((t) => t['status'] == 'waiting').toList();

        final inService =
            tickets.where((t) => t['status'] == 'in_service').toList();

        waiting.sort((a, b) =>
            (a['number'] as int).compareTo(b['number'] as int));

        final current = inService.isNotEmpty ? inService.first : null;
        final next = waiting.isNotEmpty ? waiting.first : null;

        return Column(
          children: [
            // 📊 STATS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _card("Waiting", "${waiting.length}", Icons.people),
                _card(
                    "Serving",
                    current != null ? "#${current['number']}" : "-",
                    Icons.person),
                _card(
                    "Next",
                    next != null ? "#${next['number']}" : "-",
                    Icons.skip_next),
              ],
            ),

            const SizedBox(height: 20),

            // 🔥 ACTION BUTTONS
            if (next != null && current == null)
              ElevatedButton(
                onPressed: () async {
                  await next.reference.update({
                    'status': 'in_service',
                    'assignedProviderId': providerId,
                    'startedAt': FieldValue.serverTimestamp(),
                  });
                },
                child: Text("Start Ticket #${next['number']}"),
              ),

            if (current != null)
              ElevatedButton(
                onPressed: () async {
                  await current.reference.update({
                    'status': 'done',
                    'finishedAt': FieldValue.serverTimestamp(),
                  });
                },
                child: Text("Finish Ticket #${current['number']}"),
              ),

            const SizedBox(height: 20),

            const Divider(),

            const Text("Queue"),

            // 🔥 LIST
            Expanded(
              child: ListView.builder(
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final t = tickets[index];

                  return ListTile(
                    title: Text("#${t['number']}"),
                    subtitle: Text(t['status']),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _card(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon),
            Text(value,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title),
          ],
        ),
      ),
    );
  }
}