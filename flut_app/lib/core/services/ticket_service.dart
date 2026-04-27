import 'package:cloud_firestore/cloud_firestore.dart';

class TicketService {
  static final _db = FirebaseFirestore.instance;

  // --------------------------
  // USER: CREATE TICKET
  // --------------------------
 static Future<void> createTicket({
  required String serviceId,
  required String userId,
}) async {
  final db = FirebaseFirestore.instance;

  final counterRef = db.collection('queues').doc(serviceId);

  await db.runTransaction((tx) async {
    final snapshot = await tx.get(counterRef);

    int nextNumber = 1;

    if (snapshot.exists) {
      nextNumber = snapshot['currentNumber'] + 1;
    }

    tx.set(counterRef, {
      'currentNumber': nextNumber,
    }, SetOptions(merge: true));

    final ticketRef = db.collection('tickets').doc();

    tx.set(ticketRef, {
      'number': nextNumber,
      'status': 'waiting',
      'serviceId': serviceId,
      'userId': userId,
      'assignedProviderId': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  });
}
  // --------------------------
  // ADMIN: CALL NEXT TICKET
  // --------------------------
  static Future<void> callNext(String serviceId) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('tickets')
        .get();

    final waitingTickets = snapshot.docs.where((doc) {
      final data = doc.data();
      return data['serviceId'] == serviceId &&
          data['status'] == 'waiting';
    }).toList();

    if (waitingTickets.isEmpty) {
      print("No waiting tickets for $serviceId");
      return;
    }

    waitingTickets.sort((a, b) =>
        (a['number'] as int).compareTo(b['number'] as int));

    final nextTicket = waitingTickets.first;

    await nextTicket.reference.update({
      'status': 'called',
      'calledAt': FieldValue.serverTimestamp(),
    });

    print("Called ticket #${nextTicket['number']}");
  } catch (e) {
    print("Error: $e");
  }
}

  // --------------------------
  // PROVIDER: CLAIM TICKET
  // --------------------------
  static Future<void> claimTicket(
      String ticketId, String providerId) async {
    try {
      print("Claiming ticket: $ticketId");

      final ref = _db.collection('tickets').doc(ticketId);

      await _db.runTransaction((tx) async {
        final snap = await tx.get(ref);

        if (!snap.exists) return;

        final data = snap.data() as Map<String, dynamic>;

        if (data['status'] != 'called') {
          print("Ticket not in called state");
          return;
        }

        tx.update(ref, {
          'status': 'in_service',
          'assignedProviderId': providerId,
          'startedAt': FieldValue.serverTimestamp(),
        });
      });

      print("Ticket claimed");
    } catch (e) {
      print("Error claiming ticket: $e");
    }
  }

  // --------------------------
  // PROVIDER: FINISH TICKET
  // --------------------------
  static Future<void> finishTicket(String ticketId) async {
    try {
      print("Finishing ticket: $ticketId");

      await _db.collection('tickets').doc(ticketId).update({
        'status': 'done',
        'finishedAt': FieldValue.serverTimestamp(),
      });

      print("Ticket finished");
    } catch (e) {
      print("Error finishing ticket: $e");
    }
  }

  // --------------------------
  // OPTIONAL: SKIP
  // --------------------------
  static Future<void> skipTicket(String ticketId) async {
  try {
    print("Skipping ticket: $ticketId");

    await FirebaseFirestore.instance
        .collection('tickets')
        .doc(ticketId)
        .update({
      'status': 'skipped',
      'skippedAt': FieldValue.serverTimestamp(),
    });

    print("Ticket skipped successfully");
  } catch (e) {
    print("Error skipping ticket: $e");
  }
  }
}