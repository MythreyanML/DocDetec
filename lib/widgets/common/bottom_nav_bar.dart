import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainBottomNavBar extends StatelessWidget {
  const MainBottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter.of(context);
    final String location = router.routerDelegate.currentConfiguration.uri.toString();

    return BottomNavigationBar(
      currentIndex: _calculateSelectedIndex(location),
      onTap: (int index) => _onTap(index, context),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Find Doctors',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/profile')) {
      return 1;
    }
    return 0;
  }

  void _onTap(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/profile');
        break;
    }
  }
}