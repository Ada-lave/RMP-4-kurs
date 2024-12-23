import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message, MaterialColor color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1), // Время отображения уведомления
      backgroundColor: color, // Цвет фона уведомления
      showCloseIcon: true,
      
    ),
  );
}