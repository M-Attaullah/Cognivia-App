import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cognivia_app/core/constants/app_strings.dart';
import 'package:cognivia_app/core/constants/app_colors.dart';
import 'package:cognivia_app/presentation/widgets/common/cognivia_logo.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/task_provider.dart';
import '../../../data/models/task_model.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onThemeToggle;
  final ThemeMode currentThemeMode;
  final VoidCallback? onNavigateToQuiz;
  final VoidCallback? onNavigateToTasks;
  final VoidCallback? onNavigateToChat;
  final VoidCallback? onNavigateToProfile;

  const HomeScreen({
    super.key,
    required this.onThemeToggle,
    required this.currentThemeMode,
    this.onNavigateToQuiz,
    this.onNavigateToTasks,
    this.onNavigateToChat,
    this.onNavigateToProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CogniViaLogo(size: 28),
            const SizedBox(width: 8),
            Text(
              AppStrings.appName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: IconButton(
              onPressed: onThemeToggle,
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hello Learner Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.gradientStart.withValues(alpha: 0.2)
                      : AppColors.gradientStart.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.gradientStart.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.gradientStart,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const CogniViaLogo(size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, Learner!',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.gradientStart,
                            ),
                          ),
                          Text(
                            'Ready to learn something new today?',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : AppColors.gradientStart.withValues(
                                      alpha: 0.8,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Your Progress Section
              Text(
                'Your Progress',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Consumer<QuizProvider>(
                      builder: (context, quizProvider, child) {
                        return _buildProgressCard(
                          context,
                          'Quizzes\nCompleted',
                          '${quizProvider.quizHistory.length}',
                          Icons.quiz_rounded,
                          AppColors.lightAccent,
                          isDark,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Consumer<TaskProvider>(
                      builder: (context, taskProvider, child) {
                        final completedTasks = taskProvider.tasks
                            .where(
                              (task) => task.status == TaskStatus.completed,
                            )
                            .length;
                        return _buildProgressCard(
                          context,
                          'Tasks\nDone',
                          '$completedTasks',
                          Icons.task_alt_rounded,
                          AppColors.lightSecondary,
                          isDark,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Consumer2<QuizProvider, TaskProvider>(
                      builder: (context, quizProvider, taskProvider, child) {
                        final quizScore = quizProvider.quizHistory.fold<int>(
                          0,
                          (sum, quiz) => sum + quiz.score,
                        );
                        final taskScore =
                            taskProvider.tasks
                                .where(
                                  (task) => task.status == TaskStatus.completed,
                                )
                                .length *
                            10;
                        final totalScore = quizScore * 100 + taskScore;
                        return _buildProgressCard(
                          context,
                          'Total\nScore',
                          totalScore >= 1000
                              ? '${(totalScore / 1000).toStringAsFixed(1)}K'
                              : '$totalScore',
                          Icons.star_rounded,
                          AppColors.gradientStart,
                          isDark,
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _QuickActionCard(
                    title: 'Take Quiz',
                    subtitle: 'Test your knowledge',
                    icon: Icons.quiz_rounded,
                    color: AppColors.gradientStart,
                    isDark: isDark,
                    onTap: onNavigateToQuiz ?? () {},
                  ),
                  _QuickActionCard(
                    title: 'View Tasks',
                    subtitle: 'Manage your goals',
                    icon: Icons.task_alt_rounded,
                    color: AppColors.gradientStart,
                    isDark: isDark,
                    onTap: onNavigateToTasks ?? () {},
                  ),
                  _QuickActionCard(
                    title: 'Chat',
                    subtitle: 'Connect with peers',
                    icon: Icons.chat_rounded,
                    color: AppColors.gradientStart,
                    isDark: isDark,
                    onTap: onNavigateToChat ?? () {},
                  ),
                  _QuickActionCard(
                    title: 'Profile',
                    subtitle: 'View your progress',
                    icon: Icons.person_rounded,
                    color: AppColors.gradientStart,
                    isDark: isDark,
                    onTap: onNavigateToProfile ?? () {},
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color, // Purple filled background
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white, // White icon for visibility
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black, // Text visibility
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.black.withValues(
                        alpha: 0.7,
                      ), // Subtitle visibility
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
