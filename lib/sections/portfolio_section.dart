import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart' show rootBundle;

class PortfolioSection extends StatefulWidget {
  const PortfolioSection({super.key});

  @override
  State<PortfolioSection> createState() => _PortfolioSectionState();
}

class _PortfolioSectionState extends State<PortfolioSection> {
  bool isLoadingImages = true;
  List<Map<String, String>> uiDesignItems = [];
  List<Map<String, String>> graphicDesignItems = [];
  List<Map<String, String>> developmentItems = [];
  String url = "";

  @override
  void initState() {
    super.initState();
    _loadPortfolioData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadPortfolioData() async {
    try {
      final String jsonString = await rootBundle.loadString('portfolio.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      List<Map<String, String>> processItems(String category) {
        if (jsonData.containsKey(category) && jsonData[category] is List) {
          return (jsonData[category] as List<dynamic>)
              .map((item) {
                if (item is Map) {
                  return item.map((key, value) =>
                      MapEntry(key.toString(), value?.toString() ?? ''));
                }
                return <String, String>{};
              })
              .where((item) => item.isNotEmpty && item.containsKey('image'))
              .toList();
        }
        return [];
      }

      final uiItems = processItems("uiDesignItems");
      final graphicItems = processItems("graphicDesignItems");
      final devItems = processItems("developmentItems");

      setState(() {
        uiDesignItems = uiItems;
        graphicDesignItems = graphicItems;
        developmentItems = devItems;
        isLoadingImages = false;
      });

      debugPrint("Data loaded successfully.");
    } catch (e) {
      debugPrint("Error loading portfolio data: $e");
      setState(() {
        isLoadingImages = false;
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    double ratio =
        MediaQuery.of(context).size.width / MediaQuery.of(context).size.height;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const TabBar(
            labelColor: Color.fromARGB(255, 0, 255, 177),
            indicatorColor: Color.fromARGB(255, 0, 255, 177),
            unselectedLabelColor: Colors.grey,
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: 'UI Design'),
              Tab(text: 'Graphic Design'),
              Tab(text: 'Development'),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 60),
          child: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              isLoadingImages
                  ? const Center(child: CircularProgressIndicator())
                  : buildGridView(uiDesignItems, ratio),
              isLoadingImages
                  ? const Center(child: CircularProgressIndicator())
                  : buildGridView(graphicDesignItems, ratio),
              isLoadingImages
                  ? const Center(child: CircularProgressIndicator())
                  : buildGridView(developmentItems, ratio),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildGridView(List<Map<String, String>> items, double ratio) {
    return items.isNotEmpty
        ? GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ratio < 1.4 ? 1 : 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final image = item['image'] ?? '';
              String imageUrl = 'assets/images/portfolio/$image';
              return GestureDetector(
                onTap: () {
                  _showFullScreenImage(
                    context,
                    imageUrl,
                    item['title'] ?? 'No title available',
                    item['description'] ?? 'No description available',
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'loading.gif',
                    image: imageUrl,
                    imageScale: 0.5,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(seconds: 1),
                  ),
                ),
              );
            },
          )
        : const Center(child: Text("No item available"));
  }

  void _showFullScreenImage(BuildContext context, String imagePath,
      String title, String description) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Center(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: imagePath,
                      scale: 1,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromARGB(255, 0, 255, 177))),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    left: 20,
                    right: 20,
                    child: Column(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
