import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cognivia_app/core/constants/app_strings.dart';
import 'package:cognivia_app/core/constants/app_colors.dart';
import 'package:cognivia_app/core/services/ad_manager.dart';
import 'package:cognivia_app/presentation/screens/auth/login_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final List<String>? features;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    this.features,
  });
}

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final ThemeMode currentThemeMode;

  const OnboardingScreen({
    super.key,
    required this.onThemeToggle,
    required this.currentThemeMode,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _acceptedTerms = false;
  bool _acceptedPrivacy = false;
  bool _acceptedMarketing = false;
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  bool _showAd = false;
  Timer? _adTimer;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Welcome to ${AppStrings.appName}',
      description:
          'Your intelligent companion for cognitive enhancement and social learning.',
      icon: Icons.psychology_rounded,
    ),
    OnboardingData(
      title: 'Smart Features',
      description:
          'Discover powerful tools designed to boost your learning and productivity.',
      icon: Icons.auto_awesome,
      features: [
        '🧠 AI-Powered Smart Quizzes',
        '📋 Intelligent Task Management',
        '💬 Real-time Group Chat',
        '📊 Progress Analytics',
        '🎯 Personalized Learning',
      ],
    ),
    OnboardingData(
      title: 'Privacy & Terms',
      description:
          'Join thousands of learners enhancing their cognitive abilities with CogniVia.',
      icon: Icons.rocket_launch_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    // Show ads more persistently
    _startAdCycle();
  }

  void _startAdCycle() {
    // Show ad immediately after very short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _showAd = true;
        });

        // Keep ad visible for most of the time - show for 12 seconds, hide for 3
        _adTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
          if (mounted) {
            setState(() {
              _showAd = !_showAd;
            });

            // If we just hid the ad, show it again after 3 seconds
            if (!_showAd) {
              Timer(const Duration(seconds: 3), () {
                if (mounted) {
                  setState(() {
                    _showAd = true;
                  });
                }
              });
            }
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  void _loadBannerAd() {
    if (AdManager.instance.bannerAdUnitId != null) {
      _bannerAd = BannerAd(
        adUnitId: AdManager.instance.bannerAdUnitId!,
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (_) {
            debugPrint('CogniVia: Banner ad loaded successfully');
            setState(() {
              _isBannerAdReady = true;
            });
          },
          onAdFailedToLoad: (ad, err) {
            debugPrint('CogniVia: Banner ad failed to load: $err');
            ad.dispose();
          },
        ),
      );
      _bannerAd!.load();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bannerAd?.dispose();
    _adTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0D1421)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black).withValues(
              alpha: 0.1,
            ),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              widget.currentThemeMode == ThemeMode.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
            onPressed: widget.onThemeToggle,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _pageController.animateToPage(
                _pages.length - 1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Text(
              'Skip',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(_pages[index], isDark, index);
                  },
                ),
              ),

              // Bottom navigation area with space for ad
              SafeArea(
                child: Container(
                  height: 100,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Page indicators (3 lines symbol at bottom left)
                      Row(
                        children: List.generate(
                          _pages.length,
                          (index) => Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: _currentPage == index
                                  ? AppColors.gradientStart
                                  : (isDark ? Colors.white30 : Colors.black26),
                            ),
                          ),
                        ),
                      ),

                      // Navigation button (arrow at bottom right)
                      _buildNavigationButton(isDark),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Banner Ad - More prominent and persistent
          if (_showAd && _isBannerAdReady && _bannerAd != null)
            Positioned(
              bottom: 120, // Above the navigation with more space
              left: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gradientStart.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.gradientStart.withValues(alpha: 0.5),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: AdWidget(ad: _bannerAd!),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData page, bool isDark, int index) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Icon and Title Section - Professional alignment at top-middle
            Column(
              children: [
                // Icon with gradient background
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gradientStart.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(page.icon, size: 60, color: Colors.white),
                ),

                const SizedBox(height: 24),

                // Title - Professional positioning
                Text(
                  page.title,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  page.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.black54,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Content Section
            _buildPageContent(page, isDark, index),

            // Extra spacing at bottom for ads
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(OnboardingData page, bool isDark, int index) {
    switch (index) {
      case 0:
        // Welcome page - Simple and clean
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black).withValues(
              alpha: 0.03,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.gradientStart.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.psychology_alt_outlined,
                size: 48,
                color: AppColors.gradientStart,
              ),
              const SizedBox(height: 16),
              Text(
                'AI-Powered Learning Experience',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Experience the future of learning with our intelligent platform designed to enhance your cognitive abilities.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black54,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );

      case 1:
        // Smart Features page
        return Column(
          children: page.features!
              .map(
                (feature) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withValues(
                      alpha: 0.05,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.gradientStart.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.gradientStart,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );

      case 2:
        // Privacy & Terms page
        return _buildPrivacyTermsContent(isDark);

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPrivacyTermsContent(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gradientStart.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Terms checkbox
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _acceptedTerms
                  ? AppColors.gradientStart.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _acceptedTerms
                    ? AppColors.gradientStart
                    : (isDark ? Colors.white30 : Colors.black26),
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: _acceptedTerms,
                  onChanged: (value) {
                    setState(() {
                      _acceptedTerms = value ?? false;
                    });
                  },
                  activeColor: AppColors.gradientStart,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _acceptedTerms = !_acceptedTerms;
                      });
                    },
                    child: Text(
                      '📋 I agree to the Terms of Service *',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Privacy checkbox
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _acceptedPrivacy
                  ? AppColors.gradientStart.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _acceptedPrivacy
                    ? AppColors.gradientStart
                    : (isDark ? Colors.white30 : Colors.black26),
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: _acceptedPrivacy,
                  onChanged: (value) {
                    setState(() {
                      _acceptedPrivacy = value ?? false;
                    });
                  },
                  activeColor: AppColors.gradientStart,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _acceptedPrivacy = !_acceptedPrivacy;
                      });
                    },
                    child: Text(
                      '🔒 I agree to the Privacy Policy *',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Marketing checkbox (optional)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _acceptedMarketing
                  ? AppColors.gradientStart.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _acceptedMarketing
                    ? AppColors.gradientStart
                    : (isDark ? Colors.white30 : Colors.black26),
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: _acceptedMarketing,
                  onChanged: (value) {
                    setState(() {
                      _acceptedMarketing = value ?? false;
                    });
                  },
                  activeColor: AppColors.gradientStart,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _acceptedMarketing = !_acceptedMarketing;
                      });
                    },
                    child: Text(
                      '📧 I agree to receive updates (Optional)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Required notice
          Text(
            '* Required to continue',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.red.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(bool isDark) {
    final bool isLastPage = _currentPage == _pages.length - 1;
    final bool canProceed = !isLastPage || (_acceptedTerms && _acceptedPrivacy);

    return GestureDetector(
      onTap: canProceed
          ? () {
              if (isLastPage) {
                _showInterstitialAndNavigate();
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            }
          : null,
      child: Container(
        width: isLastPage ? 100 : 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: canProceed
              ? const LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [Colors.grey.shade400, Colors.grey.shade500],
                ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: canProceed
              ? [
                  BoxShadow(
                    color: AppColors.gradientStart.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isLastPage
              ? const Text(
                  'Start',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
        ),
      ),
    );
  }

  void _showInterstitialAndNavigate() {
    if (_currentPage == _pages.length - 1 &&
        (!_acceptedTerms || !_acceptedPrivacy)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please accept Terms of Service and Privacy Policy to continue',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Show interstitial ad and navigate
    AdManager.instance.showInterstitialBeforeNavigate(() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            onThemeToggle: widget.onThemeToggle,
            currentThemeMode: widget.currentThemeMode,
          ),
        ),
      );
    });
  }
}
