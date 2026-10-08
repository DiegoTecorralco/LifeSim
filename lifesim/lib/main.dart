import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url:
        'https://lwoiwbedaiqssiqxhhvz.supabase.co',
    publishableKey:
        'sb_publishable_16ZBEInGe9bH5nZJkLBKiA_5Djf1UoL',
  );

  runApp(
    const ProviderScope(
      child: LifeSimApp(),
    ),
  );
}

class LifeSimApp
    extends StatelessWidget {
  const LifeSimApp({super.key});

  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp.router(
      title: 'LifeSim',
      debugShowCheckedModeBanner:
          false,

      theme: ThemeData(
        useMaterial3: true,

        colorScheme:
            ColorScheme.fromSeed(
          seedColor:
              Colors.indigo,
        ),

        scaffoldBackgroundColor:
            const Color(
          0xFFF7F8FC,
        ),

        inputDecorationTheme:
            InputDecorationTheme(
          filled: true,
          fillColor:
              Colors.white,

          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              14,
            ),
            borderSide:
                BorderSide.none,
          ),

          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              14,
            ),
            borderSide:
                BorderSide.none,
          ),

          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              14,
            ),
            borderSide:
                const BorderSide(
              color:
                  Colors.indigo,
              width: 2,
            ),
          ),
        ),
      ),

      routerConfig:
          appRouter,
    );
  }
}