import 'package:flutter/material.dart';

const aboutSections = [
  {
    "title": "Version",
    "subtitle": "1.0.0",
  },
  {
    "title": "API Provider",
    "subtitle":
        "We are providing our images service using the Pexels images API.",
  }
];

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

TextStyle _listTileTitleStyle = const TextStyle(color: Colors.white);

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
        titleSpacing: 0.0,
      ),
      backgroundColor: const Color(0xff303030),
      body: ListView.separated(
        itemCount: aboutSections.length,
        separatorBuilder: (context, index) => const Divider(
          color: Colors.white,
          indent: 10.0,
          endIndent: 10.0,
        ),
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              aboutSections[index]['title']!,
              style: _listTileTitleStyle,
            ),
            subtitle: Text(
              aboutSections[index]['subtitle']!,
              style: _listTileTitleStyle,
            ),
          );
        },
      ),
    );
  }
}
