// lib/features/product/presentation/screens/product_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wm_jaya/constants/app_colors.dart';
import 'package:wm_jaya/constants/app_strings.dart';
import 'package:wm_jaya/features/product/presentation/providers/product_provider.dart';
import 'package:wm_jaya/features/product/presentation/screens/product_add_screen.dart';
import 'package:wm_jaya/features/product/presentation/screens/product_list_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  ProductScreenState createState() => ProductScreenState();
}

class ProductScreenState extends State<ProductScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {}); // Memicu rebuild saat teks pencarian berubah
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProductProvider>().loadProducts();
      }
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getCategoryStyle(String category) {
    String lowerCategory = category.toLowerCase();
    if (lowerCategory.contains('makanan')) return {'icon': Icons.fastfood_outlined, 'color': Colors.orange.shade700};
    if (lowerCategory.contains('minuman')) return {'icon': Icons.local_cafe_outlined, 'color': Colors.blue.shade700};
    if (lowerCategory.contains('rokok')) return {'icon': Icons.smoking_rooms_outlined, 'color': Colors.brown.shade700};
    if (lowerCategory.contains('bensin') || lowerCategory.contains('bbm')) return {'icon': Icons.local_gas_station_outlined, 'color': Colors.red.shade700};
    if (lowerCategory.contains('kebutuhan')) return {'icon': Icons.shopping_basket_outlined, 'color': Colors.green.shade700};
    return {'icon': Icons.category_outlined, 'color': AppColors.primary};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<ProductProvider>().loadProducts(),
              color: AppColors.primary,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(AppStrings.productTitle, style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.tertiary,
      elevation: 1,
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => _navigateToAddProduct(context),
          tooltip: 'Tambah Produk',
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari kategori produk...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.categories.isEmpty) return _buildLoading();
        
        // Filter kategori berdasarkan query pencarian
        final searchQuery = _searchController.text.toLowerCase();
        final filteredCategories = provider.categories.where((cat) {
          return cat.toLowerCase().contains(searchQuery);
        }).toList();

        if (filteredCategories.isEmpty) {
          return _buildEmptyState(isSearchResult: searchQuery.isNotEmpty);
        }
        
        return _buildCategoryGrid(provider, filteredCategories);
      },
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)));
  }

  Widget _buildCategoryGrid(ProductProvider provider, List<String> categories) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final productCount = provider.products.where((p) => p.category == category).length;
        return _buildCategoryCard(category, productCount);
      },
    );
  }

  Widget _buildCategoryCard(String category, int productCount) {
    final style = _getCategoryStyle(category);
    final IconData icon = style['icon'];
    final Color color = style['color'];

    return GestureDetector(
      onTap: () => _navigateToProductList(context, category),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), spreadRadius: 1, blurRadius: 10)],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.1)),
                  child: Icon(icon, size: 36, color: color),
                ),
                const SizedBox(height: 12),
                Text(
                  category,
                  style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$productCount Produk',
                  style: GoogleFonts.lato(fontSize: 13, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey[600]),
              onSelected: (value) {
                if (value == 'edit') _showEditCategoryDialog(context, category);
                if (value == 'delete') _showDeleteCategoryDialog(context, category);
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(value: 'edit', child: Text('Ubah Nama')),
                const PopupMenuItem<String>(value: 'delete', child: Text('Hapus Kategori', style: TextStyle(color: Colors.red))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, String oldCategory) {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(text: oldCategory);
    final productProvider = context.read<ProductProvider>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Ubah Nama Kategori', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Nama Kategori Baru', border: OutlineInputBorder()),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Nama tidak boleh kosong';
              if (productProvider.categories.any((cat) => cat.toLowerCase() == value.trim().toLowerCase() && cat.toLowerCase() != oldCategory.toLowerCase())) {
                return 'Nama kategori sudah ada';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Batal', style: GoogleFonts.lato(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newCategory = controller.text.trim();
                productProvider.updateCategory(oldCategory, newCategory).then((_) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kategori berhasil diubah ke "$newCategory"')));
                }).catchError((e) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengubah kategori: $e'), backgroundColor: Colors.red));
                });
                Navigator.pop(dialogContext);
              }
            },
            child: Text('Simpan', style: GoogleFonts.lato()),
          ),
        ],
      ),
    );
  }

  void _showDeleteCategoryDialog(BuildContext context, String category) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Kategori?', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        content: Text('Semua produk dalam kategori "$category" akan dihapus permanen. Tindakan ini tidak dapat diurungkan.', style: GoogleFonts.lato()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Batal', style: GoogleFonts.lato(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ProductProvider>().deleteCategory(category);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kategori "$category" telah dihapus.'), backgroundColor: Colors.green));
            },
            child: Text('Hapus', style: GoogleFonts.lato(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState({bool isSearchResult = false}) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSearchResult ? Icons.search_off : Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              isSearchResult ? 'Kategori Tidak Ditemukan' : 'Belum Ada Kategori Produk',
              style: GoogleFonts.lato(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              isSearchResult ? 'Coba kata kunci lain untuk menemukan kategori.' : 'Tekan tombol + untuk menambahkan produk baru.',
              style: GoogleFonts.lato(fontSize: 14, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddProduct(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductAddScreen())).then((_) {
      if (mounted) context.read<ProductProvider>().loadProducts();
    });
  }

  void _navigateToProductList(BuildContext context, String category) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductListScreen(category: category)));
  }
}
