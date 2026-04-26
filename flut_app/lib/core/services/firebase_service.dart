import 'package:cloud_functions/cloud_functions.dart';

class FirebaseService {
  static final _functions = FirebaseFunctions.instance;

  /// Admin: Call Next Ticket
  static Future<void> callNext(String serviceId) async {
    final callable = _functions.httpsCallable('callNextTicket');
    await callable.call({'serviceId': serviceId});
  }

  /// Provider: Claim Ticket
  static Future<void> claimTicket(String ticketId, String providerId) async {
    final callable = _functions.httpsCallable('claimTicket');
    await callable.call({
      'ticketId': ticketId,
      'providerId': providerId,
    });
  }

  /// Provider: Finish Ticket
  static Future<void> finishTicket(String ticketId) async {
    final callable = _functions.httpsCallable('finishTicket');
    await callable.call({
      'ticketId': ticketId,
    });
  }
}