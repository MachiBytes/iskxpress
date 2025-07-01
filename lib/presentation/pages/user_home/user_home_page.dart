import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:iskxpress/core/widgets/custom_app_bar.dart';
import 'package:iskxpress/core/widgets/custom_bottom_nav_bar.dart';
import 'package:iskxpress/core/models/stall_model.dart';
import 'package:iskxpress/core/services/stall_api_service.dart';
import 'package:iskxpress/presentation/pages/user_home/widgets/user_home_content.dart';
import 'package:iskxpress/presentation/pages/user_home/widgets/user_home_search_bar.dart';
import 'package:iskxpress/core/models/category_model.dart';
import 'package:iskxpress/core/services/user_state_service.dart';
import 'package:iskxpress/presentation/pages/user_cart/user_cart_page.dart';
import 'package:iskxpress/core/helpers/navigation_helper.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  static const String routeName = 'user_home_screen';

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  List<StallModel> stalls = [];
  List<StallModel> searchResults = [];
  bool isLoading = true;
  String selectedCategory = 'All';
  String searchQuery = '';
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchStalls();
  }

  Future<void> _fetchStalls() async {
    try {
      setState(() {
        isLoading = true;
      });
      
      final fetchedStalls = await StallApiService.getStalls();
      
      setState(() {
        stalls = fetchedStalls;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error - could show a snackbar or error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load stalls: $e')),
        );
      }
    }
  }

  Future<void> _onSearchChanged(String query) async {
    setState(() {
      searchQuery = query;
    });
    if (query.isEmpty) {
      setState(() {
        isSearching = false;
        searchResults = [];
        selectedCategory = 'All';
      });
      return;
    }
    setState(() {
      isLoading = true;
      isSearching = true;
      selectedCategory = 'All';
    });
    final results = await StallApiService.searchStalls(query);
    setState(() {
      searchResults = results;
      isLoading = false;
    });
  }

  void _onFilterSelected(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  List<StallModel> get filteredStalls {
    final list = isSearching ? searchResults : stalls;
    if (selectedCategory == 'All') return list;
    return list.where((stall) => stall.categories.any((cat) => cat.name == selectedCategory)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: CustomAppBar(
        onCartPressed: () {
          final userId = UserStateService().currentUser?.id;
          if (kDebugMode) {
            debugPrint('UserHomePage: Cart pressed, userId: $userId');
            debugPrint('UserHomePage: Current user: ${UserStateService().currentUser}');
          }
          if (userId != null) {
            NavHelper.pushPageTo(context, UserCartPage(userId: userId));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User not found. Please log in again.')),
            );
          }
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 0),
      body: SafeArea(child: Column(
        children: [
          SizedBox(height: 16,),
          UserHomeSearchBar(
            onChanged: _onSearchChanged,
          ),
          SizedBox(height: 16,),
          UserHomePageContent(
            stalls: filteredStalls,
            isLoading: isLoading,
            onFilterSelected: _onFilterSelected,
          )
        ],
      )),
    );
  }
}