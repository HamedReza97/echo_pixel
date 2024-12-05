import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:echo_pixel/main.dart';

const kTitleStyle = TextStyle(
  fontFamily: "lato",
  fontSize: 32,
  fontWeight: FontWeight.bold,
);

const kSubtitleStyle = TextStyle(
  fontFamily: "lato",
  fontSize: 14,
  fontWeight: FontWeight.w100,
  color: Color.fromARGB(255, 0, 255, 177),
);

final kButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: const Color.fromARGB(255, 0, 255, 177),
  foregroundColor: Colors.black,
  minimumSize: const Size(300, 52),
);

class HomeSection extends StatefulWidget {
  const HomeSection({super.key});

  @override
  _HomeSectionState createState() => _HomeSectionState();
}

class _HomeSectionState extends State<HomeSection> {
  late Future<Map<String, String>> _stringsFuture;

  Future<Map<String, String>> _loadStrings() async {
    final String jsonString = await rootBundle.loadString('homePage.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    return {
      "title": jsonData["title"] as String,
      "subtitle": jsonData["subtitle"] as String,
      "buttonText": jsonData["buttonText"] as String,
    };
  }

  @override
  void initState() {
    super.initState();
    _stringsFuture = _loadStrings();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _stringsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error loading content: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          final strings = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: HomeSectionMedia(
              title: strings["title"]!,
              subtitle: strings["subtitle"]!,
              buttonText: strings["buttonText"]!,
            ),
          );
        } else {
          return const Center(child: Text("No content found."));
        }
      },
    );
  }
}

class HomeSectionMedia extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;

  const HomeSectionMedia({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNarrow =
        MediaQuery.of(context).size.width / MediaQuery.of(context).size.height <
            1.4;
    return isNarrow ? _buildNarrowLayout(context) : _buildWideLayout(context);
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildBanner(MediaQuery.of(context).size.height * 0.4),
        Text(
          subtitle,
          softWrap: true,
          textAlign: TextAlign.center,
          style: kSubtitleStyle,
        ),
        Text(
          title,
          softWrap: true,
          textAlign: TextAlign.center,
          style: kTitleStyle,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
        _buildContactButton(),
      ],
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            _buildBanner(MediaQuery.of(context).size.width * 0.4),
          ],
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              Text(
                subtitle,
                softWrap: true,
                textAlign: TextAlign.left,
                style: kSubtitleStyle,
              ),
              Text(
                title,
                softWrap: true,
                textAlign: TextAlign.left,
                style: kTitleStyle,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              _buildContactButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBanner(double size) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return const LinearGradient(
          colors: [Colors.black, Colors.transparent],
          begin: Alignment.center,
          end: Alignment.bottomCenter,
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: Image.asset(
        'images/Banner.png',
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildContactButton() {
    return ElevatedButton.icon(
      onPressed: () {
        homePageKey.currentState?.pageController.animateToPage(
          3,
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeInOut,
        );
      },
      style: kButtonStyle,
      label: Text(buttonText),
      icon: const Icon(Icons.call_outlined),
    );
  }
}
