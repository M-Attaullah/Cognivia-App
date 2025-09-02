import 'package:flutter/material.dart';
import 'package:cognivia_app/core/constants/app_colors.dart';
import 'package:cognivia_app/presentation/screens/home/home_screen.dart';
import 'package:cognivia_app/presentation/screens/quiz/quiz_screen.dart';
import 'package:cognivia_app/presentation/screens/tasks/tasks_screen.dart';
import 'package:cognivia_app/presentation/screens/chat/chat_screen.dart';
import 'package:cognivia_app/presentation/screens/auth/profile_screen.dart';

class ScreenInfo {
  final String title;
  final IconData icon;

  const ScreenInfo({required this.title, required this.icon});
}

class MainNavigationScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final ThemeMode currentThemeMode;

  const MainNavigationScreen({
    super.key,
    required this.onThemeToggle,
    required this.currentThemeMode,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  List<Widget> get _screens => [
    HomeScreen(
      onThemeToggle: widget.onThemeToggle,
      currentThemeMode: widget.currentThemeMode,
      onNavigateToQuiz: () => _navigateToPage(1),
      onNavigateToTasks: () => _navigateToPage(2),
      onNavigateToChat: () => _navigateToPage(3),
      onNavigateToProfile: _showProfileModal,
    ),
    QuizScreen(
      onThemeToggle: widget.onThemeToggle,
      currentThemeMode: widget.currentThemeMode,
    ),
    TasksScreen(
      onThemeToggle: widget.onThemeToggle,
      currentThemeMode: widget.currentThemeMode,
    ),
    ChatScreen(
      onThemeToggle: widget.onThemeToggle,
      currentThemeMode: widget.currentThemeMode,
    ),
  ];

  final List<ScreenInfo> _screenInfos = [
    ScreenInfo(title: 'Home', icon: Icons.home_rounded),
    ScreenInfo(title: 'Quiz Challenge', icon: Icons.quiz_rounded),
    ScreenInfo(title: 'Task Manager', icon: Icons.task_alt_rounded),
    ScreenInfo(title: 'Community Chat', icon: Icons.chat_rounded),
  ];

  Widget _buildNavItem(
    int index,
    IconData inactiveIcon,
    IconData activeIcon,
    String label,
    bool isDark,
  ) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _navigateToPage(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container - only icon in colored container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.gradientStart
                  : (isDark
                        ? Colors.grey[800]?.withOpacity(0.3)
                        : Colors.grey[200]?.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? Colors.white : AppColors.gradientStart,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          // Text with proper visibility for both modes
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? (isDark ? Colors.white : AppColors.gradientStart)
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToPage(int index) {
    if (_currentIndex == index) return; // Prevent unnecessary navigation

    setState(() {
      _currentIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(
        milliseconds: 250,
      ), // Reduced duration for better performance
      curve: Curves.easeOut, // Simpler curve for better performance
    );
  }

  void _showProfileModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: const ProfileScreen(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _currentIndex == 0
          ? null
          : AppBar(
              automaticallyImplyLeading: false,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.gradientStart.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () => _navigateToPage(0),
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.gradientStart,
                  ),
                ),
              ),
              title: Row(
                children: [
                  Icon(
                    _screenInfos[_currentIndex].icon,
                    color: AppColors.gradientStart,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _screenInfos[_currentIndex].title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: IconButton(
                    onPressed: widget.onThemeToggle,
                    icon: Icon(
                      isDark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          if (mounted) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        physics:
            const NeverScrollableScrollPhysics(), // Prevent swipe navigation to avoid conflicts
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 90, // Optimized height for better text visibility
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  0,
                  Icons.home_outlined,
                  Icons.home_rounded,
                  'Home',
                  isDark,
                ),
                _buildNavItem(
                  1,
                  Icons.quiz_outlined,
                  Icons.quiz_rounded,
                  'Quiz',
                  isDark,
                ),
                _buildNavItem(
                  2,
                  Icons.task_alt_outlined,
                  Icons.task_alt_rounded,
                  'Tasks',
                  isDark,
                ),
                _buildNavItem(
                  3,
                  Icons.chat_outlined,
                  Icons.chat_rounded,
                  'Chat',
                  isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
