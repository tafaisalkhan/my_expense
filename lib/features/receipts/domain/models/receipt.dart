class Receipt {
  final int? id;
  final String uuid;
  final String imagePath;
  final String? rawOcrText;
  final String? merchant;
  final double? detectedTotal;
  final String? detectedDate;
  final String scanDate;
  final String? fileHash;
  final String createdAt;

  const Receipt({
    this.id,
    required this.uuid,
    required this.imagePath,
    this.rawOcrText,
    this.merchant,
    this.detectedTotal,
    this.detectedDate,
    required this.scanDate,
    this.fileHash,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'uuid': uuid,
      'imagePath': imagePath,
      'rawOcrText': rawOcrText,
      'merchant': merchant,
      'detectedTotal': detectedTotal,
      'detectedDate': detectedDate,
      'scanDate': scanDate,
      'fileHash': fileHash,
      'createdAt': createdAt,
    };
  }

  factory Receipt.fromMap(Map<String, dynamic> map) {
    return Receipt(
      id: map['id'] as int?,
      uuid: map['uuid'] as String,
      imagePath: map['imagePath'] as String,
      rawOcrText: map['rawOcrText'] as String?,
      merchant: map['merchant'] as String?,
      detectedTotal: (map['detectedTotal'] as num?)?.toDouble(),
      detectedDate: map['detectedDate'] as String?,
      scanDate: map['scanDate'] as String,
      fileHash: map['fileHash'] as String?,
      createdAt: map['createdAt'] as String,
    );
  }
}
