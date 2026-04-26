class Ticket {
  final String id;
  final int number;
  final String status;

  Ticket({
    required this.id,
    required this.number,
    required this.status,
  });

  factory Ticket.fromFirestore(String id, Map<String, dynamic> data) {
    return Ticket(
      id: id,
      number: data['number'] ?? 0,
      status: data['status'] ?? 'waiting',
    );
  }
}