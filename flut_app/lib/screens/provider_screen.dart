import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/services/ticket_service.dart';

class ProviderScreen extends StatelessWidget {
  const ProviderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Provider Dashboard")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tickets')
            .orderBy('createdAt')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tickets = snapshot.data!.docs;

          final called =
              tickets.where((t) => t['status'] == 'called').toList();

          final inService =
              tickets.where((t) => t['status'] == 'in_service').toList();

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const Text("🟡 Called Tickets",
                  style: TextStyle(fontSize: 18)),

              if (called.isEmpty)
                const Text("No called tickets"),

              ...called.map((t) => Card(
                    child: ListTile(
                      title: Text("Ticket #${t['number']}"),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          await TicketService.claimTicket(
                              t.id, "provider1");
                        },
                        child: const Text("Start"),
                      ),
                    ),
                  )),

              const SizedBox(height: 20),

              const Text("🟢 In Service",
                  style: TextStyle(fontSize: 18)),

              if (inService.isEmpty)
                const Text("No active tickets"),

              ...inService.map((t) => Card(
                    child: ListTile(
                      title: Text("Ticket #${t['number']}"),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          await TicketService.finishTicket(t.id);
                        },
                        child: const Text("Finish"),
                      ),
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}