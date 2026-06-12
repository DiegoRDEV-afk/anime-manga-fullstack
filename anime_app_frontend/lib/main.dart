import '/features/home/screens/home_screen.dart';
import 'features/home/controllers/home_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

void main() {
  // Asegura que los bindings nativos (como el WebView) estén listos antes de arrancar
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(

    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeController()), // Proveedor para el HomeController
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anime App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), // Usamos tema oscuro por defecto
      home: const HomePage(), // Cargamos el reproductor directo al iniciar
    );
  }
}