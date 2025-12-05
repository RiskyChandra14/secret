class CartItem {
  final String name;
  final String image;
  final int unitPrice;
  int qty;
  final String? note;

  CartItem({
    required this.name,
    required this.image,
    required this.unitPrice,
    required this.qty,
    this.note,
  }) : assert(qty >= 0, 'qty tidak boleh negatif');

  /// Total per baris = harga satuan x qty
  int get lineTotal => unitPrice * qty;

  /// Simpan ke DB / kirim ke API
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'image': image,
      'unitPrice': unitPrice,
      'qty': qty,
      'lineTotal': lineTotal,
    };
    // Hemat storage: jangan simpan note jika null/kosong
    if (note != null && note!.trim().isNotEmpty) {
      map['note'] = note;
    }
    return map;
  }

  /// Buat dari JSON (RTDB bisa kasih int/double/String)
  factory CartItem.fromJson(Map<dynamic, dynamic> json) {
    int _parseInt(dynamic v) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) {
        // ambil hanya digit dan minus (mis. "Rp.35.000" -> 35000)
        final s = v.replaceAll(RegExp(r'[^0-9\-]'), '');
        return int.tryParse(s) ?? 0;
      }
      return 0;
    }

    return CartItem(
      name: (json['name'] as String?)?.trim() ?? '',
      image: (json['image'] as String?)?.trim() ?? '',
      unitPrice: (json['unitPrice'] is int
          ? json['unitPrice']
          : int.tryParse(json['unitPrice']?.toString() ?? '') ?? 0),
      qty: (json['qty'] is int
          ? json['qty']
          : int.tryParse(json['qty']?.toString() ?? '') ?? 1),
      note: (json['note'] as String?)?.trim(),
    );
  }

  /// Utility
  CartItem copyWith({
    String? name,
    String? image,
    int? unitPrice,
    int? qty,
    String? note,
  }) {
    return CartItem(
      name: name ?? this.name,
      image: image ?? this.image,
      unitPrice: unitPrice ?? this.unitPrice,
      qty: qty ?? this.qty,
      note: note ?? this.note,
    );
  }

  @override
  String toString() =>
      'CartItem(name: $name, unitPrice: $unitPrice, qty: $qty, note: $note)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.name == name &&
        other.image == image &&
        other.unitPrice == unitPrice &&
        other.qty == qty &&
        other.note == note;
  }

  @override
  int get hashCode =>
      name.hashCode ^
      image.hashCode ^
      unitPrice.hashCode ^
      qty.hashCode ^
      (note?.hashCode ?? 0);
}
