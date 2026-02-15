class Trip {
  final String? id;
  final String title;
  final String destination;
  final DateTime date;

  Trip({
    this.id,
    required this.title,
    required this.destination,
    required this.date,
  });

  // Convierte el objeto a un Mapa para enviar a Firebase
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'destination': destination,
      'date': date.toIso8601String(),
    };
  }

  // Crea un objeto Trip a partir de los datos de Firebase
  factory Trip.fromMap(String id, Map<String, dynamic> map) {
    return Trip(
      id: id,
      title: map['title'] ?? '',
      destination: map['destination'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
    );
  }
}
