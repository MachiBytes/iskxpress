import 'package:flutter/material.dart';
import 'package:iskxpress/core/widgets/custom_app_bar.dart';
import 'package:iskxpress/core/widgets/vendor_bottom_nav_bar.dart';
import 'package:iskxpress/presentation/pages/vendor_home/widgets/vendor_header.dart';
import 'package:iskxpress/presentation/pages/vendor_home/widgets/product_section.dart';
import 'package:iskxpress/presentation/pages/vendor_home/widgets/add_section_button.dart';
import '../../../core/services/user_state_service.dart';
import '../../../core/services/stall_state_service.dart';

class VendorHomePage extends StatefulWidget {
  const VendorHomePage({super.key});

  static const String routeName = 'vendor_home_page';

  @override
  State<VendorHomePage> createState() => _VendorHomePageState();
}

class _VendorHomePageState extends State<VendorHomePage> {
  final StallStateService _stallStateService = StallStateService();
  final UserStateService _userStateService = UserStateService();

  @override
  void initState() {
    super.initState();
    _loadStallData();
  }

  Future<void> _loadStallData() async {
    final currentUser = _userStateService.currentUser;
    if (currentUser != null) {
      await _stallStateService.loadStallForVendor(currentUser.id);
    }
  }

  // Mock data for demonstration - in real app this would come from a database
  final List<ProductSection> productSections = [
    ProductSection(
      title: 'Special Flavors',
      products: [
        Product(
          name: 'Kape Banana',
          price: 38.00,
          imageUrl: 'assets/images/demo/stalls/kape_kuripot.png',
        ),
        Product(
          name: 'Banana Latte',
          price: 40.00,
          imageUrl: 'assets/images/demo/stalls/kape_kuripot.png',
        ),
        Product(
          name: 'Kape Seasalt',
          price: 42.00,
          imageUrl: 'assets/images/demo/stalls/kape_kuripot.png',
        ),
      ],
    ),
    ProductSection(
      title: 'Iced Coffee',
      products: [
        Product(
          name: 'Choco-nut Latte',
          price: 40.00,
          imageUrl: 'assets/images/demo/stalls/kape_kuripot.png',
        ),
        Product(
          name: 'Kape Choco-nut',
          price: 38.00,
          imageUrl: 'assets/images/demo/stalls/kape_kuripot.png',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CustomAppBar(),
      bottomNavigationBar: const VendorBottomNavBar(currentIndex: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Vendor Header
            const VendorHeader(),
            
            // Product Sections
            ...productSections.map((section) => ProductSectionWidget(
              section: section,
              onEditProduct: _editProduct,
              onAddProduct: _addProduct,
            )),
            
            // Add Section Button
            AddSectionButton(onAddSection: _addSection),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _editProduct(Product product) {
    // TODO: Implement edit product functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${product.name}')),
    );
  }

  void _addProduct(String sectionTitle) {
    // TODO: Implement add product functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Add product to $sectionTitle')),
    );
  }

  void _addSection() {
    // TODO: Implement add section functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add new section')),
    );
  }
}

// Data models
class ProductSection {
  final String title;
  final List<Product> products;

  ProductSection({
    required this.title,
    required this.products,
  });
}

class Product {
  final String name;
  final double price;
  final String imageUrl;

  Product({
    required this.name,
    required this.price,
    required this.imageUrl,
  });
} 