import '/features/home/screens/home_screen.dart';
import 'features/home/controllers/home_controller.dart';
import 'features/explore/controllers/explore_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'features/main/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeController()),
        ChangeNotifierProvider(create: (_) => ExploreController()),
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
      theme: ThemeData.dark(),
      home: const MainScreen(),
    );
  }
}