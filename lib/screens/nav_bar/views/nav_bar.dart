// nav_bar.dart
import 'package:flutter/material.dart';
import 'package:kalena_admin/screens/add_product/view/add_product.dart';
import 'package:kalena_admin/screens/allProducts/view/allProduct.dart';
import 'package:kalena_admin/screens/categoryscreen/views/category_screen.dart';
import 'package:kalena_admin/screens/my_order_screen/view/my_order_screen.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final controller = NavigationController();

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        height: h / 13,
        elevation: 0,
        selectedIndex: controller.selectedIndex,
        onDestinationSelected: (index) {
          setState(
            () {
              controller.selectedIndex = index;
            },
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.add),
            label: 'Listing',
          ),
          NavigationDestination(
            icon: Icon(Icons.category),
            label: 'Category',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.view_agenda_outlined,
            ),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Order',
          ),
          // NavigationDestination(
          //     icon: Icon(Icons.work_outline_sharp), label: 'Work'),
          // NavigationDestination(icon: Icon(Iconsax.user), label: 'Profile'),
        ],
      ),
      body: controller.screens[controller.selectedIndex],
    );
  }
}

class NavigationController {
  int selectedIndex = 0;

  final screens = [
    const ProductListingScreen(),
    const AddCategory(),
    const AllProducts(),
    const MyOrderScreen(),
  ];
}
