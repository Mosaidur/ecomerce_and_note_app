import 'package:ecom_and_note_app/shared/theme%20provider/themeProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'feature/auth/presentation/loginScreen.dart';
import 'feature/ecom/presentation/provider/product_provider.dart';
import 'feature/ecom/presentation/screen/product_list_screen.dart';
import 'feature/home screen/homeScreen.dart';
import 'feature/notes/data/repository/note_repository_impl.dart';
import 'feature/notes/presentaiton/provider/note_provider.dart';
import 'feature/notes/presentaiton/screen/note_edit_screen.dart';
import 'feature/notes/presentaiton/screen/note_list_screen.dart';
import 'feature/splash screen/splashScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  final noteRepository = NoteRepositoryImpl(sharedPreferences);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),  // Add this
        ChangeNotifierProvider(create: (_) => NoteProvider(repository: noteRepository)),
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
    '/notes': (context) {
    final prefs = ModalRoute.of(context)!.settings.arguments as SharedPreferences;
    return ChangeNotifierProvider(
    create: (_) => NoteProvider(
    repository: NoteRepositoryImpl(prefs),
    )..loadNotes(),
    child: const NoteListScreen(),
    );
    },

        '/noteEdit': (context) {
          final noteProvider = Provider.of<NoteProvider>(context, listen: false);
          return ChangeNotifierProvider.value(
            value: noteProvider,
            child: const NoteEditScreen(),
          );
        },



      },
    );
  }
}
