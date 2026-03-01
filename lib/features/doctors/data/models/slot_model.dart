class SlotModel {
  final String id;
  final DateTime start;
  final DateTime end;
  final int capacity;
  final String ownerId;
  final String? ruleId;

  SlotModel({
    required this.id,
    required this.start,
    required this.end,
    required this.capacity,
    required this.ownerId,
    this.ruleId,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      id: json['id'] as String,
      start: DateTime.parse(json['start'] as String).toLocal(),
      end: DateTime.parse(json['end'] as String).toLocal(),
      capacity: json['capacity'] as int? ?? 1,
      ownerId: json['ownerId'] as String,
      ruleId: json['ruleId'] as String?,
    );
  }
}
