import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

class PortfolioSection extends StatefulWidget {
  const PortfolioSection({super.key});
  @override
  State<PortfolioSection> createState() => _PortfolioSectionState();
}

class _PortfolioSectionState extends State<PortfolioSection> {
  bool isLoadingImages = true;
  List<Map<String, String>> uiDesignItems = [];
  List<Map<String, String>> graphicDesignItems = [];

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
            .map((item) => item is Map
                ? item.map((key, value) => MapEntry(key.toString(), value?.toString() ?? ''))
                : <String, String>{})
            .where((item) => item.isNotEmpty && item.containsKey('image'))
            .toList();
      }
      return [];
    }

    final uiItems = processItems("uiDesignItems");
    final graphicItems = processItems("graphicDesignItems");

    setState(() {
      uiDesignItems = uiItems;
      graphicDesignItems = graphicItems;
      isLoadingImages = false;
    });

    debugPrint("Data loaded successfully.");
  } on Exception catch (e) {
    debugPrint("Error loading portfolio data: $e");
    setState(() {
      isLoadingImages = false;
    });
  }
}

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
              Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(
        'images/GitHub-Logo.png',
        height: 200,
      ),
      const SizedBox(height: 20),
      ElevatedButton.icon(
        icon: const Icon(Icons.open_in_browser),
        label: const Text("Visit My GitHub"),
        onPressed: () => launchUrl(Uri.parse("https://github.com/HamedReza97")),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 0, 255, 177),
          foregroundColor: Colors.black,
          minimumSize: const Size(200, 52),
      ),
      )
    ],
  ),
),

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
              crossAxisSpacing: 30,
              mainAxisSpacing: 30,
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
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
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
              );
            },
          )
        : const Center(child: Text("No item available"));
  }

  void _showFullScreenImage(
    BuildContext context, String imagePath, String title, String description) {
  showDialog(
    context: context,
    barrierDismissible: true, // Closes dialog when tapping outside
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pop(); // Close on tap outside
          },
          child: Stack(
            children: [
              // Interactive Viewer for zoom and pan
              InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 1.0,
                maxScale: 4.0,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: imagePath,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color.fromARGB(255, 0, 255, 177)),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 40,
                      ),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


}