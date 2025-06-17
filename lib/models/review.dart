class Review {
  final int? id;
  final String comment;
  final DateTime dateAdded;

  Review({
    this.id,
    required this.comment,
    required this.dateAdded,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'comment': comment,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'],
      comment: map['comment'],
      dateAdded: DateTime.parse(map['dateAdded']),
    );
  }
}
