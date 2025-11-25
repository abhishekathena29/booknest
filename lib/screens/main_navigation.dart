import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'my_library_screen.dart';
import 'community_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ExploreScreen(),
    const MyLibraryScreen(),
    const CommunityScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: isDark ? const Color(0xFF1F2C34) : Colors.white,
          indicatorColor: isDark
              ? const Color(0xFF2D7A7B).withValues(alpha: 0.3)
              : const Color(0xFFD2691E).withValues(alpha: 0.2),
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.home_outlined,
                color: _currentIndex == 0
                    ? (isDark
                          ? const Color(0xFF5BA9AA)
                          : const Color(0xFFD2691E))
                    : Colors.grey,
              ),
              selectedIcon: Icon(
                Icons.home,
                color: isDark
                    ? const Color(0xFF5BA9AA)
                    : const Color(0xFFD2691E),
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.search,
                color: _currentIndex == 1
                    ? (isDark
                          ? const Color(0xFF5BA9AA)
                          : const Color(0xFFD2691E))
                    : Colors.grey,
              ),
              selectedIcon: Icon(
                Icons.search,
                color: isDark
                    ? const Color(0xFF5BA9AA)
                    : const Color(0xFFD2691E),
              ),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.library_books_outlined,
                color: _currentIndex == 2
                    ? (isDark
                          ? const Color(0xFF5BA9AA)
                          : const Color(0xFFD2691E))
                    : Colors.grey,
              ),
              selectedIcon: Icon(
                Icons.library_books,
                color: isDark
                    ? const Color(0xFF5BA9AA)
                    : const Color(0xFFD2691E),
              ),
              label: 'My Library',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.groups_outlined,
                color: _currentIndex == 3
                    ? (isDark
                          ? const Color(0xFF5BA9AA)
                          : const Color(0xFFD2691E))
                    : Colors.grey,
              ),
              selectedIcon: Icon(
                Icons.groups,
                color: isDark
                    ? const Color(0xFF5BA9AA)
                    : const Color(0xFFD2691E),
              ),
              label: 'Community',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.person_outline,
                color: _currentIndex == 4
                    ? (isDark
                          ? const Color(0xFF5BA9AA)
                          : const Color(0xFFD2691E))
                    : Colors.grey,
              ),
              selectedIcon: Icon(
                Icons.person,
                color: isDark
                    ? const Color(0xFF5BA9AA)
                    : const Color(0xFFD2691E),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
