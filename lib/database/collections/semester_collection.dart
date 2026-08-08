import 'package:isar/isar.dart';

part 'semester_collection.g.dart';

@collection
class Semester {
  Semester();

  Id id = Isar.autoIncrement;

  @Index()
  int profileId = 0;

  late String name;

  /// Stored as normalized local calendar date (year, month, day)
  late DateTime startDate;

  /// Stored as normalized local calendar date (year, month, day)
  DateTime? endDate;

  String? description;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileId': profileId,
      'name': name,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Semester.fromMap(Map<String, dynamic> map) {
    return Semester()
      ..id = map['id'] ?? Isar.autoIncrement
      ..profileId = map['profileId'] ?? 0
      ..name = map['name'] ?? 'Unknown'
      ..startDate = map['startDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['startDate']) 
          : DateTime.now()
      ..endDate = map['endDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['endDate']) 
          : null
      ..description = map['description']
      ..createdAt = map['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt']) 
          : DateTime.now()
      ..updatedAt = map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt']) 
          : DateTime.now();
  }
}
