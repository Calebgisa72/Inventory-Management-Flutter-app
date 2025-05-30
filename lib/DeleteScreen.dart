import 'package:flutter/material.dart';

class DeleteScreen extends StatelessWidget {
  const DeleteScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Container(
        height: 470,
        width: 320,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(107, 59, 225, 0.984),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(35.0),
              child: Container(
                height: 120.0,
                width: 120.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100.0),
                  color: const Color.fromARGB(250, 237, 220, 220),
                ),
                child: Center(
                  child: Image.asset(
                    "lib/icons/garbage.png",
                    height: 85,
                    width: 85,
                  ),
                ),
              ),
            ),
            Container(
                child: const Text("   You are about to delete a product  ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17.0,
                      color: Color.fromARGB(250, 227, 219, 219),
                    ))),
            const SizedBox(
              height: 30,
            ),
            Container(
                child: const Text(
              "     This will  delete your product from  ",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17.0,
                  color: Color.fromARGB(250, 237, 218, 218)),
            )),
            Container(
              child: const Text(
                " the Catalog Are you sure?            ",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17.0,
                    color: Color.fromARGB(250, 216, 205, 205)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 80.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    color: const Color.fromARGB(250, 241, 225, 225),
                    textColor: Colors.black,
                    height: 50.0,
                    onPressed: () {},
                    child: const Text(
                      ' Cancel ',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    color: const Color.fromARGB(250, 238, 221, 221),
                    textColor: Colors.black,
                    height: 50.0,
                    onPressed: () {},
                    child: const Text(
                      '   Delete   ',
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
