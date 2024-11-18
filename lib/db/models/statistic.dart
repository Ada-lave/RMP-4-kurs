class Statistic {
  int id;
  double fileSize;
  DateTime startAt;
  DateTime endAt;

  Statistic(this.id, this.fileSize, this.startAt, this.endAt);

  Map<String, Object?> toMap() {
    return {
      "id": id,
      "file_size": fileSize,
      "start_at": startAt,
      "end_at": endAt
    };
  }

  static Statistic fromMap(Map<String, dynamic> map) {
    return Statistic(
        map['id'], map['file_size'], map['start_at'], map['end_at']);
  }
}
