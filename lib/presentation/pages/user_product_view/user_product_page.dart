import 'package:flutter/material.dart';
import 'package:iskxpress/presentation/pages/user_product_view/widgets/user_product_app_bar.dart';

class UserProductPage extends StatefulWidget {
  const UserProductPage({super.key});

  static const String routeName = 'user_product_page';

  @override
  State<UserProductPage> createState() => _UserProductPageState();
}

class _UserProductPageState extends State<UserProductPage> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: UserProductAppBar(),
      body: Column(
        children: [
          // TabBar (to be added with controller)
          Container(
            height: 48, // placeholder for now
            color: Colors.grey[300],
            alignment: Alignment.center,
            child: const Text('TabBar here'),
          ),

          // Scrollable list (to be implemented)
          const Expanded(
            child: Center(child: Text('Scrollable food list here')),
          ),
        ],
      ),
    );
  }
}
