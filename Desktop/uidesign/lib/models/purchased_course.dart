class PurchasedCourse {
  String id;
  String userId;
  List<String> courseIds;
  List<String> pdfIds; // Added pdfIds
  DateTime purchasedAt;
  bool pending;
  bool show;
  String message;
  String number;
  double totalPrice;

  PurchasedCourse({
    required this.id,
    required this.userId,
    required this.courseIds,
    required this.pdfIds, // Added pdfIds to constructor
    required this.purchasedAt,
    required this.pending,
    required this.show,
    required this.message,
    required this.number,
    required this.totalPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userId": userId,
      "courseIds": courseIds,
      "pdfIds": pdfIds, // Added pdfIds to toJson
      "purchasedAt": purchasedAt.toIso8601String(),
      "pending": pending,
      "show": show,
      "message": message,
      "number": number,
      "totalPrice": totalPrice,
    };
  }

  factory PurchasedCourse.fromJson(Map<String, dynamic> json) {
    return PurchasedCourse(
      id: json["id"],
      userId: json["userId"],
      courseIds: List<String>.from(json["courseIds"]),
      pdfIds: json["pdfIds"] != null ? List<String>.from(json["pdfIds"]) : [], // Added pdfIds from json
      purchasedAt: DateTime.parse(json["purchasedAt"]),
      pending: json["pending"],
      show: json["show"],
      message: json["message"],
      number: json["number"],
      totalPrice: json["totalPrice"] != null ? json["totalPrice"].toDouble() : 0.0,
    );
  }
}