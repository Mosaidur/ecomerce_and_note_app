import 'package:ecom_and_note_app/shared/theme%20provider/themeProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'feature/auth/presentation/loginScreen.dart';
import 'feature/ecom/presentation/provider/product_provider.dart';
import 'feature/ecom/presentation/screen/product_list_screen.dart';
import 'feature/home screen/homeScreen.dart';
import 'feature/splash screen/splashScreen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),  // Add this
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Login Demo',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(primarySwatch: Colors.teal, brightness: Brightness.light),
      darkTheme: ThemeData(primarySwatch: Colors.teal, brightness: Brightness.dark),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/productListScreen': (context) => const ProductListScreen(),
      },
    );
  }
}
