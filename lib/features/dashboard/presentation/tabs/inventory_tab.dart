import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quvexai_mobile/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:quvexai_mobile/features/inventory/data/models/inventory_item_model.dart';

class InventoryTab extends ConsumerWidget {
  const InventoryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inventoryProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(child: Text('Hata: ${state.errorMessage}'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final item = state.items[index];
        return ProductCard(item: item);
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final InventoryItemModel item;
  const ProductCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.network(
              item.imageUrl,
              fit: BoxFit.cover,

              // Resim yüklenirken... (Arkadaşınız bunu eklemiş olabilir)
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              },

              // --- 👇👇👇 LÜTFEN BU KISMI EKLEYİN VEYA GÜNCELLEYİN 👇👇👇 ---
              // Resim yüklenirken HATA ALIRSA...
              errorBuilder: (context, error, stackTrace) {
                // --- HATA AYIKLAMA KODU ---
                // Hatayı terminale/konsola YAZDIR
                print('RESİM YÜKLEME HATASI (${item.name}): $error');
                // --- HATA AYIKLAMA KODU SONU ---

                // Hata ikonunu kırmızı renkte göster
                return const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.red,
                    size: 40,
                  ),
                );
              },
              // --- 👆👆👆 GÜNCELLEME SONU 👆👆👆 ---
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text('Adet: ${item.quantity}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
