import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management/ImageTextCard.dart';
import 'package:inventory_management/NotificationScreen.dart';
import 'package:inventory_management/SearchBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('uid');
  if (context.mounted) GoRouter.of(context).go('/login');
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Row(
                children: [
                  Spacer(),
                  IconButton(
                    padding: const EdgeInsets.only(bottom: 5),
                    onPressed: () {
                      _logout(context);
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const NotificationPage(),
                      //   ),
                      // );
                    },
                    icon: const Icon(
                      Icons.notifications_none_outlined,
                      size: 30,
                    ),
                  ),
                ],
              ),
              const Row(
                children: [
                  SizedBox(width: 30),
                  Text(
                    "Home",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const MySlider(),
              const SizedBox(height: 15),
              const SearChBar(),
              const SizedBox(height: 15),
              const DisplayCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class MySlider extends StatefulWidget {
  const MySlider({super.key});

  @override
  _MySliderState createState() => _MySliderState();
}

class _MySliderState extends State<MySlider> {
  int _currentSlide = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> carouselItems = [
      buildCarouselItem(
        title: "Lorem ipsum dolor sit amet.",
        content:
            "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        total: 100,
        stockIn: 50,
        stockOut: 20,
      ),
      buildCarouselItem(
        title: "Today",
        date: "Aug 22",
        content: "Here is a summary of today's updates. Stay tuned for more!",
        total: 120,
        stockIn: 60,
        stockOut: 30,
      ),
      buildCarouselItem(
        title: "Yesterday",
        date: "Aug 21",
        content: "Recap of yesterday's events. Don't miss out on any detail!",
        total: 90,
        stockIn: 40,
        stockOut: 10,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Stack(
            children: [
              CarouselSlider(
                items: carouselItems,
                options: CarouselOptions(
                  autoPlayCurve: Curves.decelerate,
                  autoPlay: true,
                  height: 220,
                  viewportFraction: 1.0,
                  enlargeCenterPage: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentSlide = index;
                    });
                  },
                ),
              ),
              Positioned(
                top: 8.0,
                right: 20.0,
                child: CarouselStatus(
                  itemCount: carouselItems.length,
                  currentSlide: _currentSlide,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildCarouselItem(
      {String? title,
      String? date,
      required String content,
      required int total,
      required int stockIn,
      required int stockOut}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Color.fromRGBO(107, 59, 225, 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (title != null)
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          if (date != null) HeroSec(date),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              content,
              style: const TextStyle(fontSize: 14, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.white, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildVerticalBarInfo("Total", total.toString()),
              buildVerticalBarInfo("Stock In", stockIn.toString()),
              buildVerticalBarInfo("Stock Out", stockOut.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildVerticalBarInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: Colors.white),
        ),
      ],
    );
  }
}

class CarouselStatus extends StatelessWidget {
  final int itemCount;
  final int currentSlide;

  const CarouselStatus({
    super.key,
    required this.itemCount,
    required this.currentSlide,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int index = 0; index < itemCount; index++)
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: currentSlide == index
                  ? const Color.fromARGB(255, 30, 69, 224)
                  : Colors.white,
            ),
          ),
      ],
    );
  }
}

class HeroSec extends StatelessWidget {
  final String date;

  const HeroSec(this.date, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      date,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    );
  }
}
