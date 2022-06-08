import 'package:flutter/material.dart';
import 'package:ml_depression/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ml_depression/Pages/HomeWidget.dart';

class StartupWidget extends StatelessWidget {
  const StartupWidget({Key? key}) : super(key: key);

  final List<Item> settingsItems = const [
    Item("Number of tests", "Choose how many times you want to do the test each day.", Icons.numbers)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Startup page"),
      ),
      body: Column(
        children: [...List.generate(
          settingsItems.length,
          (index) => ItemWidget(
            settingsItems[index],
          ),
        ),
        FloatingActionButton.extended(onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          prefs.setBool(didStartupKey, true);

          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeWidget()));
        }, label: Text("Save"))
        ]
      ),
    );
  }
}

class ItemWidget extends StatelessWidget {
  const ItemWidget(this.item, {Key? key}) : super(key: key);

  final Item item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      item.icon,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          item.title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        item.description,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(
          thickness: 2,
          height: 0,
        )
      ],
    );
  }
}

class Item {
  const Item(this.title, this.description, this.icon);

  final String title;
  final String description;
  final IconData icon;
}
