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
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(107, 59, 225, 1),
        title: const Text(
          'Bikaneza ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // IconButton(
          //   onPressed: () {
          //     // Navigate to notifications page
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => const NotificationPage(),
          //       ),
          //     );
          //   },
          //   icon: const Icon(
          //     Icons.notifications_none_outlined,
          //     color: Colors.white,
          //     size: 28,
          //   ),
          // ),
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 30),

              // Welcome message card
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(107, 59, 225, 0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Welcome to Bikaneza",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Keep tracking your stock efficiently",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2,
                            color: Colors.white.withOpacity(0.9)),
                        const SizedBox(width: 8),
                        Text(
                          "Manage your inventory with ease",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),
              // const MySlider(),
              // const SizedBox(height: 15),
              // const SearChBar(),
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
    List<Widget> carouselItems = [];

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
