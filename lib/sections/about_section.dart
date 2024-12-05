import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutSection extends StatefulWidget {
  AboutSection({super.key});

  @override
  _AboutSectionState createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection> {
  late Future<Map<String, dynamic>> _aboutData;

  @override
  void initState() {
    super.initState();
    _aboutData = loadJson();
  }

  Future<Map<String, dynamic>> loadJson() async {
    String jsonString = await rootBundle.loadString('about_data.json');
    return jsonDecode(jsonString);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _aboutData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          Map<String, dynamic> jsonData = snapshot.data!;
          var profile = jsonData['profile'];
          String name = profile['name'];
          String title = profile['title'];
          String description = profile['description'];
          String image = profile['image'];
          var employmentHistory = jsonData['employmentHistory'];
          List<Map<String, String>> skills = (jsonData['skills'] as List)
              .map((skill) => {
                    'title': skill['title'] as String,
                    'point': skill['point'] as String,
                  })
              .toList();

          return Padding(
              padding: EdgeInsets.symmetric(horizontal: 60),
              child: ListView(
                scrollDirection: Axis.vertical,
                children: [
                  MediaLayout(
                    name: name,
                    title: title,
                    description: description,
                    image: 'images/$image',
                    employmentHistory: employmentHistory,
                    skills: skills,
                  ),
                ],
              ));
        }
      },
    );
  }
}

class MediaLayout extends StatelessWidget {
  final String name;
  final String title;
  final String description;
  final String image;
  final List<dynamic> employmentHistory;
  final List<Map<String, String>> skills;

  const MediaLayout({
    super.key,
    required this.name,
    required this.title,
    required this.description,
    required this.image,
    required this.employmentHistory,
    required this.skills,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (MediaQuery.of(context).size.width /
                MediaQuery.of(context).size.height <
            1.4) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      colors: [Colors.black, Colors.transparent],
                      begin: Alignment.center,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      image: DecorationImage(
                        image: AssetImage(image),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'lato',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 255, 177),
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'lato',
                    fontSize: 16,
                    fontWeight: FontWeight.w100,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'lato',
                    fontSize: 14,
                    fontWeight: FontWeight.w100,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 40),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Employment History",
                    style: TextStyle(
                      fontFamily: 'lato',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                ...employmentHistory.map<Widget>((item) {
                  return EmploymentHistoryNarrow(
                    title: item['title'],
                    date: item['date'],
                    subItems: List<String>.from(item['subItems']),
                  );
                }).toList(),
                SizedBox(height: 40),
                Align(
                  alignment: Alignment.topLeft,
                  child: const Text(
                    "Skills",
                    style: TextStyle(
                        fontFamily: 'lato',
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Skills(skills: skills),
                SizedBox(
                  height: 100,
                )
              ],
            ),
          );
        } else {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) {
                              return const LinearGradient(
                                      colors: [
                                    Colors.black,
                                    Colors.transparent
                                  ],
                                      begin: Alignment.center,
                                      end: Alignment.bottomCenter)
                                  .createShader(bounds);
                            },
                            blendMode: BlendMode.dstIn,
                            child: Container(
                              width: 240,
                              height: 240,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                image: DecorationImage(
                                  image: AssetImage(image),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          SizedBox(width: 30),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontFamily: 'lato',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 0, 255, 177),
                                  ),
                                  softWrap: true,
                                  textAlign: TextAlign.left,
                                ),
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontFamily: 'lato',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w100,
                                  ),
                                  softWrap: true,
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  description,
                                  style: TextStyle(
                                    fontFamily: 'lato',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w100,
                                    color: Colors.grey,
                                  ),
                                  softWrap: true,
                                  textAlign: TextAlign.justify,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Employment History",
                                  style: TextStyle(
                                      fontFamily: 'lato',
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      ...employmentHistory.map<Widget>((item) {
                        return EmploymentHistoryWide(
                          title: item['title'],
                          date: item['date'],
                          subItems: List<String>.from(item['subItems']),
                        );
                      }).toList(),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
                SizedBox(
                  width: 50,
                ),
                Expanded(
                    child: Column(children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Skills",
                      style: TextStyle(
                          fontFamily: 'lato',
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Skills(skills: skills),
                ]))
              ],
            ),
          );
        }
      },
    );
  }
}

class EmploymentHistoryWide extends StatelessWidget {
  final String title;
  final String date;
  final List<String> subItems;

  const EmploymentHistoryWide({
    super.key,
    required this.date,
    required this.title,
    required this.subItems,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontFamily: 'lato',
                  fontSize: 16,
                  color: Color.fromARGB(255, 0, 255, 177),
                  fontWeight: FontWeight.normal),
            ),
            SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  height: 2,
                  color: Colors.grey,
                ),
              ),
            ),
            SizedBox(width: 10),
            Text(date),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: BulletList(items: subItems),
            ),
          ],
        ),
      ],
    );
  }
}

class EmploymentHistoryNarrow extends StatelessWidget {
  final String title;
  final String date;
  final List<String> subItems;

  const EmploymentHistoryNarrow({
    super.key,
    required this.date,
    required this.title,
    required this.subItems,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          title,
          style: TextStyle(
              fontFamily: 'lato',
              fontSize: 16,
              color: Color.fromARGB(255, 0, 255, 177),
              fontWeight: FontWeight.normal),
        ),
        SizedBox(width: 10),
        Text(date),
        SizedBox(height: 10),
         BulletList(items: subItems),
      ],
    );
  }
}

class BulletList extends StatelessWidget {
  final List<String> items;

  const BulletList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "• ",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                item,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class Skills extends StatefulWidget {
  final List<Map<String, String>> skills;

  const Skills({super.key, required this.skills});

  @override
  _SkillsState createState() => _SkillsState();
}

class _SkillsState extends State<Skills> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      widget.skills.length,
      (index) => AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      ),
    );

    _animations = List.generate(
      widget.skills.length,
      (index) => Tween<double>(
        begin: 0.0,
        end: int.parse(widget.skills[index]['point']!) / 100.0,
      ).animate(
        CurvedAnimation(
          parent: _controllers[index],
          curve: Curves.easeInOut,
        ),
      ),
    );

    for (var controller in _controllers) {
      controller.forward();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int crossAxisCount =
        MediaQuery.of(context).size.width / MediaQuery.of(context).size.height <
                1.4
            ? 1
            : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisExtent: MediaQuery.of(context).size.height * 0.08,
        mainAxisSpacing: 8,
      ),
      itemCount: widget.skills.length,
      itemBuilder: (context, index) {
        final skill = widget.skills[index];
        return Container(
          padding: EdgeInsets.only(top: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                skill['title']!,
                style: TextStyle(
                  fontFamily: 'lato',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              AnimatedBuilder(
                animation: _animations[index],
                builder: (context, child) {
                  return LinearProgressIndicator(
                    backgroundColor: Color.fromARGB(255, 0, 27, 28),
                    color: Color.fromARGB(255, 0, 255, 177),
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    value: _animations[index].value,
                    minHeight: 10,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
