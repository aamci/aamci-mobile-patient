class AppointmentKindModel {
  final String id;
  final String name;
  final int durationMins;
  final double? price;
  final String? color;

  AppointmentKindModel({
    required this.id,
    required this.name,
    required this.durationMins,
    this.price,
    this.color,
  });

  factory AppointmentKindModel.fromJson(Map<String, dynamic> json) {
    return AppointmentKindModel(
      id: json['id'] as String,
      name: json['name'] as String,
      durationMins: json['durationMins'] as int,
      price: (json['price'] as num?)?.toDouble(),
      color: json['color'] as String?,
    );
  }
}
