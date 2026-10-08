import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // Inicializa Flutter antes de inicializar Supabase
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Supabase
  await Supabase.initialize(
    url: 'https://lwoiwbedaiqssiqxhhvz.supabase.co',
    publishableKey: 'sb_publishable_16ZBEInGe9bH5nZJkLBKiA_5Djf1UoL',
  );

  // Inicia la aplicación
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LifeSim',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LifeSim'),
      ),
      body: const Center(
        child: Text(
          'Supabase conectado',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}