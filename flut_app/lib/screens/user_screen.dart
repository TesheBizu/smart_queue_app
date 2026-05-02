import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/services/ticket_service.dart';
import '../core/services/auth_service.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  String? selectedServiceId;
  final String userId = "FirebaseAuth.instance.currentUser!.uid";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Queue"),
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
            // 🔥 SERVICE DROPDOWN
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

            const SizedBox(height: 20),

            // 🔥 GET TICKET BUTTON
            ElevatedButton(
              onPressed: selectedServiceId == null
              ? null
              : () async {
                final ticketNumber = await TicketService.createTicket(
                  serviceId: selectedServiceId!,
                  userId: userId,
                   );

          if (ticketNumber != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("🎟 Your ticket number is #$ticketNumber"),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: const Text("Get Ticket"),
  ),

            const SizedBox(height: 20),

            const Divider(),

            // 🔥 MAIN CONTENT
            Expanded(
              child: selectedServiceId == null
                  ? _buildWelcomeUI()
                  : _buildServiceStatus(),
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
          Icon(Icons.person, size: 80, color: Colors.blue),
          SizedBox(height: 20),
          Text(
            "Welcome 👋",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text("Select a service to get your queue status"),
        ],
      ),
    );
  }

  // =========================
  // 🔵 SERVICE STATUS UI
  // =========================
  Widget _buildServiceStatus() {
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

        // 🔥 My tickets for this service
        final myTickets =
            tickets.where((t) => t['userId'] == userId).toList();

        if (myTickets.isEmpty) {
          return const Center(child: Text("No ticket for this service"));
        }

        // 🔥 Sort tickets
        tickets.sort((a, b) =>
            (a['number'] as int).compareTo(b['number'] as int));

        myTickets.sort((a, b) =>
            (a['number'] as int).compareTo(b['number'] as int));

        final myTicket = myTickets.last;

        // 🔥 Waiting tickets
        final waiting = tickets
            .where((t) => t['status'] == 'waiting')
            .toList();

        waiting.sort((a, b) =>
            (a['number'] as int).compareTo(b['number'] as int));

        // 🔥 Position
        int position = 0;
        for (int i = 0; i < waiting.length; i++) {
          if (waiting[i].id == myTicket.id) {
            position = i + 1;
            break;
          }
        }

        // 🔥 Next ticket preview
        final nextTicket =
            waiting.isNotEmpty ? waiting.first : null;

        return Column(
          children: [
            // =========================
            // 📊 STATUS CARD
            // =========================
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      "Your Ticket",
                      style: TextStyle(fontSize: 16),
                      ),
        const SizedBox(height: 10),
        Text(
          "#${myTicket['number']}",
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text("Status: ${myTicket['status']}"),
        ],
      ),
    ),
  ),

            const SizedBox(height: 20),

            // =========================
            // 📊 POSITION
            // =========================
            if (myTicket['status'] == 'waiting')
              Text(
                position == 0
                    ? "Waiting..."
                    : "You are #$position in queue",
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),

            if (myTicket['status'] == 'called')
              const Text(
                "👉 It's your turn!",
                style: TextStyle(fontSize: 20, color: Colors.green),
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

            const SizedBox(height: 20),

            const Divider(),

            // =========================
            // 🔥 NEXT TICKET PREVIEW
            // =========================
            if (nextTicket != null)
              Column(
                children: [
                  const Text(
                    "Next Ticket",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "#${nextTicket['number']}",
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}