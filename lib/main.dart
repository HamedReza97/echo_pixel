import 'package:flutter/material.dart';
import 'sections/home_section.dart';
import 'sections/portfolio_section.dart';
import 'sections/about_section.dart';
import 'sections/contact_section.dart';

void main() {
  runApp(const AsroDesign());
}

final GlobalKey<_MyHomePageState> homePageKey = GlobalKey<_MyHomePageState>();

class AsroDesign extends StatelessWidget {
  const AsroDesign({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Echo Pixel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 255, 177),
        ),
        useMaterial3: true,
        fontFamily: 'lato',
        textTheme: Typography.whiteMountainView,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(
              key: homePageKey,
              title: "Echo Pixel",
            ),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
    PageController get pageController => _pageController;
    final Map<int, Widget> _cachedSections = {};

  int _currentPage = 0;
  bool _isLoading = true; 

  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat(reverse: true);

  late final Animation<double> _opacityAnimation = Tween<double>(
    begin: 0.3,
    end: 1.0,
  ).animate(
    CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isLoading = false; 
      });
    });
    
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onHorizontalDrag(DragEndDetails details) {
    if (details.primaryVelocity != null) {
      if (details.primaryVelocity! > 0) {
        if (_currentPage > 0) {
          setState(() {
            _currentPage--;
            _pageController.animateToPage(
              _currentPage,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
            );
          });
        }
      } else if (details.primaryVelocity! < 0) {
        if (_currentPage < 3) {
          setState(() {
            _currentPage++;
            _pageController.animateToPage(
              _currentPage,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
            );
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _buildBackgroundGradient(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        body: _isLoading ? _buildLoadingScreen() : _buildMainContent(),
      ),
    );
  }

  BoxDecoration _buildBackgroundGradient() {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color.fromARGB(255, 0, 27, 28),
          Color.fromARGB(255, 0, 1, 1),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  AppBar _buildAppBar() {
    final screenSize = MediaQuery.of(context).size.width;
    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: screenSize * 0.02),
          Image.asset('images/Logo.png', height: 28),
          const Spacer(),
          _buildStatusIndicator(),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    final screenSize = MediaQuery.of(context).size.width;
    return Container(
      height: 42,
      margin: EdgeInsets.only(right: screenSize * 0.02),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 5),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 27, 28),
        border: Border.all(
          color: const Color.fromARGB(255, 9, 48, 36),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _opacityAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: const Text(
                  "•",
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 255, 177),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 5),
          const Text(
            "Available for work",
            style: TextStyle(
              color: Color.fromARGB(255, 0, 255, 177),
              fontFamily: 'lato',
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Loading screen
  Widget _buildLoadingScreen() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(const Color.fromARGB(255, 0, 255, 177)),
        strokeWidth: 5.0,
      ),
    );
  }

  // Main content of the page
  Widget _buildMainContent() {
    return GestureDetector(
      onHorizontalDragEnd: _onHorizontalDrag,
      child: Stack(
        children: [
          _buildPageView(),
          _buildBottomNavBar(context),
        ],
      ),
    );
  }

Widget _buildPageView() {
  return PageView(
    controller: _pageController,
    scrollDirection: Axis.horizontal,
    children: List.generate(4, (index) {
      if (!_cachedSections.containsKey(index)) {
        switch (index) {
          case 0:
            _cachedSections[index] = HomeSection();
            break;
          case 1:
            _cachedSections[index] = PortfolioSection();
            break;
          case 2:
            _cachedSections[index] = AboutSection();
            break;
          case 3:
            _cachedSections[index] = ContactSection();
            break;
        }
      }
      return _cachedSections[index]!;
    }),
  );
}


  Widget _buildBottomNavBar(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(200, 0, 10, 11),
              Color.fromARGB(255, 0, 10, 11),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        height: 70,
        width: MediaQuery.of(context).size.width > 700
            ? MediaQuery.of(context).size.width * 0.5
            : MediaQuery.of(context).size.width * 0.8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavButton(context, "Home", 0),
            _buildNavButton(context, "Portfolio", 1),
            _buildNavButton(context, "About", 2),
            _buildNavButton(context, "Contact", 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String label, int page) {
    return TextButton(
      onPressed: () {
        _pageController.animateToPage(
          page,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      },
      style: TextButton.styleFrom(
        foregroundColor: _currentPage == page
            ? const Color.fromARGB(255, 0, 255, 177)
            : Colors.grey,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(top: 4.0),
            height: 4.0,
            width: _currentPage == page ? 40.0 : 0.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: _currentPage == page
                  ? const Color.fromARGB(255, 0, 255, 177)
                  : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
