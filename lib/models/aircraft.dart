class Aircraft {
  final String id;
  final String name;
  final Map<String, Map<String, int>> pidSettings;
  final DateTime createdAt;
  final DateTime lastAnalyzed;

  Aircraft({
    required this.id,
    required this.name,
    required this.pidSettings,
    required this.createdAt,
    required this.lastAnalyzed,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'pidSettings': pidSettings.map((key, value) => 
        MapEntry(key, value.map((k, v) => MapEntry(k, v))),
      ),
      'createdAt': createdAt.toIso8601String(),
      'lastAnalyzed': lastAnalyzed.toIso8601String(),
    };
  }

  factory Aircraft.fromJson(Map<String, dynamic> json) {
    return Aircraft(
      id: json['id'] as String,
      name: json['name'] as String,
      pidSettings: (json['pidSettings'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          (value as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, v as int),
          ),
        ),
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastAnalyzed: DateTime.parse(json['lastAnalyzed'] as String),
    );
  }
}