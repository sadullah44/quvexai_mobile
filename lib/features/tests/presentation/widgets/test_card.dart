import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quvexai_mobile/features/tests/data/models/test_model.dart';

/// Bu widget, 'TestlerTab' içinde, listedeki her bir
/// testi temsil eden "kart"tır.
class TestCard extends StatelessWidget {
  // Dışarıdan, Kişi 1'in Modelini ('TestModel') alır
  final TestModel test;

  const TestCard({super.key, required this.test});

  @override
  Widget build(BuildContext context) {
    // Tıklanabilir ve gölgeli bir kart oluşturuyoruz
    return Card(
      elevation: 3, // Hafif gölge
      margin: const EdgeInsets.symmetric(vertical: 8),
      clipBehavior: Clip.antiAlias, // Köşeleri yuvarlatmak için
      child: ListTile(
        // Kartın solundaki ikon
        leading: const Icon(Icons.article_outlined, size: 40),

        // Test Adı (Modelden gelen 'name')
        title: Text(
          test.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        // Alt başlık (Modelden gelen diğer bilgiler)
        subtitle: Text(
          "${test.category} • ${test.estimatedTimeMins} Dakika • Zorluk: ${test.difficulty}",
        ),

        // Kartın sağındaki "detaya git" ikonu
        trailing: const Icon(Icons.chevron_right),

        // Tıklama olayı
        onTap: () {
          context.push('/tests/${test.id}', extra: test);
        },
      ),
    );
  }
}
