import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/services/ticket_service.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  String? selectedServiceId;
  final String userId = "user1";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Smart Queue")),
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

                if (services.isEmpty) {
                  return const Text("No services");
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

            // 🔥 GET TICKET
            ElevatedButton(
              onPressed: () async {
                if (selectedServiceId == null) return;

                await TicketService.createTicket(
                  serviceId: selectedServiceId!,
                  userId: userId,
                );
              },
              child: const Text("Get Ticket"),
            ),

            const SizedBox(height: 30),

            const Text(
              "Your Status",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // 🔥 ADVANCED LIVE FILTERING
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('tickets')
                    .where('serviceId', isEqualTo: selectedServiceId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final allTickets = snapshot.data!.docs;

                  // 🔥 My ticket for this service
                  final myTickets = allTickets
                      .where((t) => t['userId'] == userId)
                      .toList();

                  if (myTickets.isEmpty) {
                    return const Center(
                        child: Text("No ticket for this service"));
                  }

                  // Latest ticket
                  myTickets.sort((a, b) =>
                      (a['number'] as int)
                          .compareTo(b['number'] as int));

                  final myTicket = myTickets.last;

                  // 🔥 Waiting tickets for this service
                  final waitingTickets = allTickets
                      .where((t) => t['status'] == 'waiting')
                      .toList();

                  waitingTickets.sort((a, b) =>
                      (a['number'] as int)
                          .compareTo(b['number'] as int));

                  int position = 0;

                  for (int i = 0; i < waitingTickets.length; i++) {
                    if (waitingTickets[i].id == myTicket.id) {
                      position = i + 1;
                      break;
                    }
                  }

                  return Column(
                    children: [
                      Card(
                        child: ListTile(
                          title:
                              Text("Ticket #${myTicket['number']}"),
                          subtitle:
                              Text("Status: ${myTicket['status']}"),
                        ),
                      ),

                      const SizedBox(height: 20),

                      if (myTicket['status'] == 'waiting')
                        Text(
                          position == 0
                              ? "Waiting..."
                              : "You are #$position in queue",
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),

                      if (myTicket['status'] == 'called')
                        const Text(
                          "👉 It's your turn!",
                          style: TextStyle(
                              fontSize: 20, color: Colors.green),
                        ),

                      if (myTicket['status'] == 'in_service')
                        const Text(
                          "🟢 Being served",
                          style: TextStyle(fontSize: 20),
                        ),

                      if (myTicket['status'] == 'done')
                        const Text(
                          "✅ Completed",
                          style: TextStyle(fontSize: 20),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}