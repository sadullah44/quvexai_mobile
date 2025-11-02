import 'package:equatable/equatable.dart';
import 'package:quvexai_mobile/features/inventory/data/models/inventory_item_model.dart';

/// Bu sınıf, "Envanter" özelliğinin anlık "fotoğrafıdır".
/// Arayüz (UI), bu duruma ('State') bakarak ne çizeceğine karar verir.
class InventoryState extends Equatable {
  // 1. Yükleniyor durumu: JSON okunurken true olur.
  //    Arayüz (UI) bunu dinleyerek 'CircularProgressIndicator' gösterir.
  final bool isLoading;

  // 2. Hata mesajı: JSON okuma başarısız olursa
  //    bu alanda saklanır. UI bunu dinleyerek hata mesajı gösterir.
  final String? errorMessage;

  // 3. EN ÖNEMLİ ALAN: Ürünlerin Listesi
  //    JSON'dan başarıyla okunan 'InventoryItemModel' listesi
  //    burada saklanır. UI bu listeyi alıp 'GridView'de çizer.
  final List<InventoryItemModel> items;

  // 4. Standart Kurucu (Constructor)
  const InventoryState({
    required this.isLoading,
    this.errorMessage,
    required this.items,
  });

  // 5. initial: Durumun "başlangıç" (varsayılan) halini tanımlar.
  //    Uygulama ilk açıldığında durum budur:
  //    yüklenmiyor, hata yok, ürün listesi boş.
  factory InventoryState.initial() {
    return const InventoryState(
      isLoading: false,
      errorMessage: null,
      items: [], // Başlangıçta liste boştur
    );
  }

  // 6. copyWith: Durumu GÜNCELLEMEK için (Değişmezlik kuralı)
  //    'AuthNotifier' gibi, 'InventoryNotifier' da bu metodu
  //    kullanarak yeni 'state' kopyaları oluşturur.
  InventoryState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<InventoryItemModel>? items,
  }) {
    return InventoryState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      items: items ?? this.items,
    );
  }

  // 7. Equatable için gerekli (props listesi)
  @override
  List<Object?> get props => [isLoading, errorMessage, items];
}
