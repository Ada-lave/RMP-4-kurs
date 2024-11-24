class Statistic {
  int? id;
  int fileSize;
  String startAt;
  String endAt;

  Statistic({this.id, required this.fileSize, required this.startAt, required this.endAt});

  Map<String, Object?> toMap() {
    return {"file_size": fileSize, "start_at": startAt, "end_at": endAt};
  }

  static Statistic fromMap(Map<String, dynamic> map) {
    return Statistic(
        id: map["id"], fileSize: map['file_size'], startAt: map['start_at'], endAt: map['end_at']);
  }
}
