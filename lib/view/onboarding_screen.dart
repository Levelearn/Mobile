import 'package:app/model/onboarding.dart';
import 'package:app/utils/colors.dart';
import 'package:app/view/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'login_screen.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingModel> onboardingData = [
    OnboardingModel(
        image: 'lib/assets/vectors/socialshare-primary.png',
        title: 'Extra Time College',
        description:
            'Tingkatkan Pemahaman Kuliahmu, Kapan Saja, Di Mana Saja!'),
    OnboardingModel(
        image: 'lib/assets/vectors/gaming-primary.png',
        title: 'Gamified Learning',
        description: 'Belajar Sambil Bermain, Jadikan Ilmu sebagai Temanmu!'),
    OnboardingModel(
        image: 'lib/assets/vectors/socialinfluencer-primary.png',
        title: 'Levelearn!',
        description: 'Level Up Your Learn! Become Advanced!'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'lib/assets/pictures/background-pattern.png',
              fit: BoxFit.cover,
            ),
          ),
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingData.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return OnboardingPage(model: onboardingData[index]);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                  bottom: 40.0), // Padding untuk pagination
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: onboardingData.length,
                    effect: WormEffect(
                      dotColor: Colors.grey,
                      activeDotColor: AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _currentPage < onboardingData.length - 1
                            ? () {
                                _pageController.nextPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              }
                            : () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              await prefs.setBool('firstLaunch', false);

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()),
                              );
                            },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:  AppColors.primaryColor,
                        ),
                        child: Text(
                          _currentPage < onboardingData.length - 1
                              ? 'Selanjutnya'
                              : 'Mulai',
                          style: TextStyle(fontFamily: 'DIN_Next_Rounded', color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingModel model;

  OnboardingPage({required this.model});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            height: 128,
          ),
          Image.asset(model.image),
          SizedBox(height: 20),
          Text(
            model.title,
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'DIN_Next_Rounded',
                color: AppColors.primaryColor
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              model.description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontFamily: 'DIN_Next_Rounded'
              ),
            ),
          ),
        ],
      ),
    );
  }
}
