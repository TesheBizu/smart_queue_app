class Service {
  final String id;
  final String name;

  Service({
    required this.id,
    required this.name,
  });

  factory Service.fromFirestore(String id, Map<String, dynamic> data) {
    return Service(
      id: id,
      name: data['name'] ?? '',
    );
  }
}