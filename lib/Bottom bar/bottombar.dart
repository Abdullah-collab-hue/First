import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import '../bottom_navigationBar/bottom_navigation.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  double _ratingValue = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff263851),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Text(
            "Do you like our app?",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Give us a quick rating so we know",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                "if you like",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: RatingStars(
              value: _ratingValue,
              onValueChanged: (value) {
                setState(() {
                  _ratingValue = value;
                });
              },
              starBuilder: (index, color) => Icon(
                Icons.star,
                size: 40,
                color: color,
              ),
              starCount: 5,
              starSize: 60,
              valueLabelVisibility: false,
              maxValue: 5,
              starSpacing: 1,
              animationDuration: const Duration(milliseconds: 1000),
              starOffColor: const Color(0xffe7e8ea),
              starColor: Colors.yellow,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 46,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xff6187BB),
              borderRadius: BorderRadius.circular(23),
            ),
            child: const Center(
              child: Text(
                "RATE US ON GOOGLE PLAY",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BottomNavigationBarExample(),
                  ),
                );
              },
              child: const Text(
                "NOT NOW",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}