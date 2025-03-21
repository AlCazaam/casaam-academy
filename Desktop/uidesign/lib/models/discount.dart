class Discount {
  String id;
  List<String> courseIds;
  double percentage;
  String couponCode;
  DateTime startDate;
  DateTime endDate;
  bool isActive;

  Discount({
    required this.id,
    required this.courseIds,
    required this.percentage,
    required this.couponCode,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "courseIds": courseIds,
      "percentage": percentage,
      "couponCode": couponCode,
      "startDate": startDate.toIso8601String(),
      "endDate": endDate.toIso8601String(),
      "isActive": isActive,
    };
  }

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      id: json["id"],
      courseIds: List<String>.from(json["courseIds"]),
      percentage: (json["percentage"] as num).toDouble(),
      couponCode: json["couponCode"],
      startDate: DateTime.parse(json["startDate"]),
      endDate: DateTime.parse(json["endDate"]),
      isActive: json["isActive"],
    );
  }
}