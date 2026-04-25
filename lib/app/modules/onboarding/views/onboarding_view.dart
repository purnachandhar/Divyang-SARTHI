import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intro_screen_onboarding_flutter/intro_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../theme/app_theme.dart';

class OnboardingView extends StatelessWidget {
  OnboardingView({super.key});

  final List<Introduction> list = [
    Introduction(
      title: 'Empowering Divyangjan',
      titleTextStyle:
          AppTheme.lightTheme.textTheme.headlineMedium!.copyWith(fontSize: 20),
      subTitle:
          'A platform introduced for supporting and empowering people with disabilities.',
      subTitleTextStyle: AppTheme.lightTheme.textTheme.bodyLarge!,
      imageUrl: 'assets/images/int_1.png',
    ),
    Introduction(
      title: 'Expert Support',
      titleTextStyle:
          AppTheme.lightTheme.textTheme.headlineMedium!.copyWith(fontSize: 20),
      subTitle:
          'Connect with professionals and institutions for holistic education and care.',
      subTitleTextStyle: AppTheme.lightTheme.textTheme.bodyLarge!,
      imageUrl: 'assets/images/int_2.png',
    ),
    Introduction(
      title: 'Inclusive Community',
      titleTextStyle:
          AppTheme.lightTheme.textTheme.headlineMedium!.copyWith(fontSize: 20),
      subTitle:
          'Join a community that values inclusion and accessibility for everyone.',
      subTitleTextStyle: AppTheme.lightTheme.textTheme.bodyLarge!,
      imageUrl: 'assets/images/int_3.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return IntroScreenOnboarding(
      introductionList: list,
      onTapSkipButton: () => _completeOnboarding(context),
      foregroundColor: AppTheme.primaryColor,
    );
  }

  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_onboarding_done', true);
    Get.offAllNamed('/login');
  }
}
