// 1. Equatable (G3'te eklemiştik)
// İki model nesnesinin 'eşit' olup olmadığını kolayca
// karşılaştırmak için kullanıyoruz.
import 'package:equatable/equatable.dart';

/// Bu sınıf, 'inventory.json' dosyamızdaki TEK BİR ÜRÜN'ün
/// Dart kodundaki "kalıbıdır" (modelidir).
/// Bu, ham JSON metnini, kodumuzun anlayabileceği
/// bir 'Dart nesnesine' dönüştüren "tercümandır".
class InventoryItemModel extends Equatable {
  // 2. Alanlar (Fields): JSON'daki her 'anahtara' (key) karşılık gelir.
  final String id;
  final String name;
  final String qrCode;
  final int quantity;
  final String lastUpdated;
  final String imageUrl;

  // 3. Standart Kurucu (Constructor)
  // Bu, Dart kodunun bu nesneyi 'inşa etmesi' için kullanılır.
  const InventoryItemModel({
    required this.id,
    required this.name,
    required this.qrCode,
    required this.quantity,
    required this.lastUpdated,
    required this.imageUrl,
  });

  // 4. "Fabrika" Kurucusu (Factory Constructor) - JSON TERCÜMANI
  /// Bu 'fabrika' metodu, 'Map<String, dynamic>' (Flutter'ın
  /// JSON verisine verdiği ad) tipinde bir veri alır ve onu
  /// 'InventoryItemModel' nesnesine dönüştürür.
  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      // JSON'daki 'id' anahtarını oku -> 'id' alanına ata
      id: json['id'] as String,

      // JSON'daki 'name' anahtarını oku -> 'name' alanına ata
      name: json['name'] as String,

      // JSON'daki 'qr_code' anahtarını oku -> 'qrCode' alanına ata
      // (Dart'ta 'camelCase' (qrCode), JSON'da 'snake_case' (qr_code)
      // kullanmak yaygın bir standarttır, dönüşümü burada yaparız)
      qrCode: json['qr_code'] as String,

      // JSON'daki 'quantity' anahtarını oku -> 'quantity' alanına ata
      quantity: json['quantity'] as int,

      // JSON'daki 'last_updated' anahtarını oku -> 'lastUpdated' alanına ata
      lastUpdated: json['last_updated'] as String,

      // JSON'daki 'image_url' anahtarını oku -> 'imageUrl' alanına ata
      imageUrl: json['image_url'] as String,
    );
  }

  // 5. Equatable (Karşılaştırma) için gerekli
  // Bu, Riverpod'a iki envanter ürününün 'id'si aynıysa,
  // onları "aynı" ürün olarak kabul etmesini söyler.
  @override
  List<Object?> get props => [
    id,
    name,
    quantity,
    qrCode,
    lastUpdated,
    imageUrl,
  ];
}
