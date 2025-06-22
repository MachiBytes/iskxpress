import 'package:flutter/material.dart';
import 'package:iskxpress/core/widgets/custom_app_bar.dart';
import 'package:iskxpress/core/widgets/custom_bottom_nav_bar.dart';
import 'package:iskxpress/presentation/pages/user_home/widgets/user_home_content.dart';
import 'package:iskxpress/presentation/pages/user_home/widgets/user_home_search_bar.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  static const String routeName = 'user_home_screen';

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  List<Map<String, dynamic>> stalls = [];

  @override
  void initState() {
    super.initState();
    // Seeded stalls data (in a real DDD setup, this would come from the domain/application layer)
    stalls = [
      {
        "imagePath": "assets/images/demo/stalls/bento_express.png",
        "name": "Bento Express",
        "number": "Stall 6",
        "description": "Bento Express serves delicious Asian snacks and meals."
      },
      {
        "imagePath": "assets/images/demo/stalls/fewa_ni_virgin.png",
        "name": "FEWA ni Virgin",
        "number": "Stall 10",
        "description": "FEWA ni Virgin grills flavorful chicken meals."
      },
      {
        "imagePath": "assets/images/demo/stalls/chick_n_rice.png",
        "name": "Chick N' Rice",
        "number": "Stall 14",
        "description": "Chick N' Rice offers a variety of home-cooked meals for an affordable price."
      },
      {
        "imagePath": "assets/images/demo/stalls/full_cup.png",
        "name": "Full Cup",
        "number": "Stall 11",
        "description": "Full Cup brews rich coffee blends and tasty pastries."
      },
      {
        "imagePath": "assets/images/demo/stalls/kape_kuripot.png",
        "name": "Kape Kuripot",
        "number": "Stall 9",
        "description": "Kape Kuripot brews rich coffee blends with a special flavor coming out each..."
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: CustomAppBar(),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 0),
      body: SafeArea(child: Column(
        children: [
          SizedBox(height: 16,),
          UserHomeSearchBar(),
          SizedBox(height: 16,),
          UserHomePageContent(stalls: stalls)
        ],
      )),
    );
  }
}