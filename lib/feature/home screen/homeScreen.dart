import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../../shared/theme provider/themeProvider.dart';
import '../ecom/presentation/provider/product_provider.dart';
import '../ecom/presentation/screen/product_list_screen.dart';
import '../notes/data/repository/note_repository_impl.dart';
import '../notes/presentaiton/provider/note_provider.dart';
import '../notes/presentaiton/screen/note_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  void initState() {
    super.initState();
    // NOTE: Removed context.read<ProductProvider>() here to avoid ProviderNotFoundException
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          Center(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => ProductProvider()..loadProducts(),
                      child: const ProductListScreen(),
                    ),
                  ),
                );
              },
              child: const Text(
                '🎉 Welcome to the Home Screen!\nTap here to see products',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => NoteProvider(repository: NoteRepositoryImpl(prefs))..loadNotes(),
                    child: const NoteListScreen(),
                  ),

                ),
              );
            },
            child: const Text(
              '📝 Tap here to see notes',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

        ],
      ),
    );
  }
}
