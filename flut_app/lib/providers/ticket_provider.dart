import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ticket.dart';

final ticketsProvider = StreamProvider((ref) {
  return FirebaseFirestore.instance
      .collection('tickets')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return Ticket.fromFirestore(doc.id, doc.data());
    }).toList();
  });
});