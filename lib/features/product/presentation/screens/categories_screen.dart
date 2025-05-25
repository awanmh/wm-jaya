// lib/features/product/presentation/screens/categories_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wm_jaya/features/product/presentation/providers/product_provider.dart';
import 'package:wm_jaya/features/product/presentation/screens/product_add_screen.dart';
import 'package:wm_jaya/features/product/presentation/screens/product_list_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  CategoriesScreenState createState() => CategoriesScreenState();
}

class CategoriesScreenState extends State<CategoriesScreen> {
  @override
  @override
void initState() {
  super.initState();
  // Load products asynchronously when the screen is initialized
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (context.mounted) {
      context.read<ProductProvider>().loadProducts();
    }
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProductAddScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          // Checking if the provider is loading the data
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Display categories in a ListView
          return ListView.builder(
            itemCount: provider.categories.length,
            itemBuilder: (context, index) {
              final category = provider.categories[index];
              return ListTile(
                title: Text(category),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductListScreen(category: category),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
