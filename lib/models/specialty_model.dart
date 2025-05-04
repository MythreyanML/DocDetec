class SpecialtyModel {
  final String id;
  final String name;
  final String? description;

  SpecialtyModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory SpecialtyModel.fromMap(String id, Map<String, dynamic> map) {
    return SpecialtyModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
    };
  }
}