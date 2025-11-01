import 'package:flutter/material.dart';

/// Bu, projenin herhangi bir yerinden çağırabileceğimiz
/// yeniden kullanılabilir bir 'Snackbar' (Uyarı) fonksiyonudur.
void showSnackbar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  // Önce, ekranda varsa mevcut snackbar'ı gizle (üst üste binmesinler)
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  // Yeni snackbar'ı göster
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),

      // Hata ise (isError = true) temanın 'error' rengini (genellikle kırmızı) kullan,
      // değilse (başarı ise) 'Colors.green' kullan.
      backgroundColor: isError
          ? Theme.of(context).colorScheme.error
          : Colors.green,

      behavior: SnackBarBehavior.floating, // Ekranın altında 'yüzen' stil
    ),
  );
}
