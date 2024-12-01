class TransactionType {
  int? typeId;
  String typeName;

  TransactionType({
    this.typeId,
    required this.typeName,
  });

  Map<String, dynamic> toMap() {
    return {
      'type_id': typeId,
      'type_name': typeName,
    };
  }

  factory TransactionType.fromMap(Map<String, dynamic> map) {
    return TransactionType(
      typeId: map['type_id'],
      typeName: map['type_name'],
    );
  }
}
