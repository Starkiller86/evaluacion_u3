import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/deliveries_page.dart';
import 'pages/delivery_detail_page.dart';
import 'pages/photo_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paquexpress - Agente',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/deliveries': (context) => const DeliveriesPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/delivery_detail') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => DeliveryDetailPage(
              delivery: args['delivery'],
            ),
          );
        }

        if (settings.name == '/photo_page') {
          final args = settings.arguments as Map<String, dynamic>;

          return MaterialPageRoute(
            builder: (_) => PhotoPage(
              deliveryId: args['deliveryId'],
              deliveryLat: args['deliveryLat'],
              deliveryLon: args['deliveryLon'],
            ),
          );
        }

        return null;
      },
    );
  }
}
