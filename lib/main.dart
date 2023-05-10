import 'package:biton_ai/screens/resultsScreen.dart';
import 'package:biton_ai/screens/wordpress/auth_screen.dart';
import 'package:biton_ai/screens/wordpress/woo_posts_screen.dart';
import 'package:biton_ai/widgets/resultsList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'common/constants.dart';
import 'screens/homeScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (BuildContext context, Widget? child) =>
          MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Flutter Demo',
              theme: ThemeData(primarySwatch: Colors.blue),
              // home: const HomeScreen()
              home: ResultsScreen()
          ),
    );
  }
}


class MyScreen extends StatefulWidget {
  const MyScreen({Key? key}) : super(key: key);

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  List<String> animals = [
    "Dog",
    "Cat",
    "Lion",
    "Tiger",
    "Elephant",
    "Giraffe",
  ];
  List<String> phones = [
    "Samsung",
    "iPhone",
    "Huawei",
    "Xiaomi",
    "Oppo",
    "Vivo",
  ];
  List<String> games = [
    "Call of Duty",
    "Fortnite",
    "PUBG",
    "GTA V",
    "Minecraft",
    "FIFA 22",
  ];

  List<String> selectedItems = [];

  List<String> currentList = [];

  void selectItem(String item) {
    setState(() {
      selectedItems.add(item);
      currentList = phones;
    });
  }

  void removeItem(String item) {
    setState(() {
      selectedItems.remove(item);
      currentList = animals;
    });
  }

  @override
  void initState() {
    super.initState();
    currentList = animals;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Screen"),
      ),
      body: Row(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: currentList.length,
              itemBuilder: (context, index) {
                final item = currentList[index];
                return ChoiceChip(
                  label: Text(item),
                  selected: selectedItems.contains(item),
                  onSelected: (selected) {
                    if (selected) {
                      selectItem(item);
                    }
                  },
                );
              },
            ),
          ),
          VerticalDivider(),
          Expanded(
            child: ListView.builder(
              itemCount: selectedItems.length,
              itemBuilder: (context, index) {
                final item = selectedItems[index];
                return ListTile(
                  title: Text(item),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      removeItem(item);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

