import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'explore/explore_screen.dart';
import 'library/my_library_screen.dart';
import 'community/community_screen.dart';
import 'profile/profile_screen.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedColor = theme.colorScheme.primary;
    final unselectedColor = theme.colorScheme.onSurface.withValues(alpha: 0.58);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.08),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          height: 72,
          backgroundColor: isDark
              ? const Color(0xFF1F2C34).withValues(alpha: 0.94)
              : Colors.white.withValues(alpha: 0.96),
          indicatorColor: selectedColor.withValues(alpha: 0.14),
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.home_outlined,
                color: _currentIndex == 0 ? selectedColor : unselectedColor,
              ),
              selectedIcon: Icon(Icons.home, color: selectedColor),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.search,
                color: _currentIndex == 1 ? selectedColor : unselectedColor,
              ),
              selectedIcon: Icon(Icons.search, color: selectedColor),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.library_books_outlined,
                color: _currentIndex == 2 ? selectedColor : unselectedColor,
              ),
              selectedIcon: Icon(Icons.library_books, color: selectedColor),
              label: 'My Library',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.groups_outlined,
                color: _currentIndex == 3 ? selectedColor : unselectedColor,
              ),
              selectedIcon: Icon(Icons.groups, color: selectedColor),
              label: 'Forum',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.person_outline,
                color: _currentIndex == 4 ? selectedColor : unselectedColor,
              ),
              selectedIcon: Icon(Icons.person, color: selectedColor),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
