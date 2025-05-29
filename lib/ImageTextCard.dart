import 'package:flutter/material.dart';
import 'package:inventory_management/AddItemScreen.dart';
import 'package:inventory_management/ItemsList.dart';
import 'package:inventory_management/ReportPage.dart';
import 'package:inventory_management/stockout.dart';

class ImageTextCard extends StatelessWidget {
  final String imagePath;
  final String text;
  final bool isTrue;

  const ImageTextCard({
    super.key,
    required this.imagePath,
    required this.text,
    this.isTrue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            if (text == "Add Items") {
              return const AddProductForm();
            } else if (text == "Inventory Count") {
              return ReportPage();
            } else if (text == "Inventory") {
              return const ItemsScreen();
            } else {
              return const StockOutPage();
            }
          }));
        },
        child: Card(
          margin: const EdgeInsets.all(7),
          color: isTrue ? Colors.white : const Color.fromRGBO(107, 59, 225, 1),
          shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              side: isTrue
                  ? const BorderSide(
                      width: 4, color: Color.fromRGBO(107, 59, 225, 1))
                  : BorderSide.none),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 80,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                child: Center(
                  child: Text(
                    text,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isTrue
                            ? const Color.fromRGBO(107, 59, 225, 1)
                            : Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DisplayCard extends StatelessWidget {
  const DisplayCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Row(
              children: [
                ImageTextCard(
                  imagePath: 'assets/images/inventory.png',
                  text: 'Add Items',
                  isTrue: false,
                ),
                ImageTextCard(
                  imagePath: 'assets/images/stockout.png',
                  text: 'Stock Out',
                  isTrue: true,
                )
              ],
            ),
            Row(
              children: [
                ImageTextCard(
                  imagePath: 'assets/images/report.png',
                  text: 'Inventory Count',
                  isTrue: true,
                ),
                ImageTextCard(
                  imagePath: 'assets/images/inventorylist.png',
                  text: 'Inventory',
                  isTrue: false,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
