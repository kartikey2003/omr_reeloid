import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:new_u/splash.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';

import 'add-main.dart';
import 'h.dart';
import 'multi_audio_player.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _currentIndex = 0;
  int? _pressedIndex;
  int _selectedIndex = 0;
  VideoPlayerController? _videoController;

  final List<Widget> _pages = [
    Homepage(),
    AddMain(),
    Reelss(),
    VideoPlayerScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<String> images = [
    "https://images.unsplash.com/photo-1506744038136-46273834b3fb",
    "https://images.unsplash.com/photo-1508921912186-1d1a45ebb3c1",
    "https://images.unsplash.com/photo-1470770903676-69b98201ea1c",
    "https://images.unsplash.com/photo-1529156069898-49953e39b3ac",
    "https://plus.unsplash.com/premium_photo-1752231846149-ddd0a41c479e?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxmZWF0dXJlZC1waG90b3MtZmVlZHwyfHx8ZW58MHx8fHx8",
  ];

  final List<String> videoUrls = [
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    'https://download.blender.org/durian/trailer/sintel_trailer-480p.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
  ];

  @override
  void dispose() {
    _stopVideo();
    super.dispose();
  }

  Future<void> _startVideo(int index, bool isPressed) async {
    await _stopVideo();

    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(videoUrls[index]),
    );
    if (isPressed) {
      try {
        await _videoController!.initialize();
        await _videoController!.play();
        setState(() {
          _pressedIndex = index;
        });
      } catch (e) {
        debugPrint("Video failed to load: $e");
      }
    }
  }

  Future<void> _stopVideo() async {
    if (_videoController != null) {
      await _videoController!.pause();
      await _videoController!.dispose();
      _videoController = null;
    }

    setState(() {
      _pressedIndex = null;
    });
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      images.shuffle();
      videoUrls.shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return SafeArea(
      child:Scaffold(
          backgroundColor: Colors.grey[900],
          appBar: AppBar(
            title: Text(
              "Sliderzz",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 24,
              ),
            ),
            centerTitle: true,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black54, Colors.black45],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            elevation: 4,
          ),
          body: _selectedIndex == 0
              ? homeBody(screenSize)
              : _pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.black54,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home'),
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.cyclone_outlined),
              //   label: 'Reels',
              // ),
              BottomNavigationBarItem(
                icon: Icon(Icons.alarm_add_sharp),
                label: 'Adds',
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.cyclone_outlined),
                  label: 'reel_audio'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.gamepad),
                  label: 'gg'),
            ],
          ),
        ),
      );
  }

  Widget homeBody(Size screenSize) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: Colors.black12,
      backgroundColor: Colors.black87,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            slider(screenSize),
            _dotsIndicator(),
            // _sectionTitle("Latest Shows"),
            // listV(screenSize),
            // _sectionTitle("Latest Shows"),
            // listH(screenSize),
            //_sectionTitle("Upcoming Shows"),
            //listV(screenSize),
          ],
        ),
      ),
    );
  }

  Widget slider(Size screenSize) {
    return CarouselSlider.builder(
      itemCount: images.length,
      itemBuilder: (context, index, realIdx) {
        bool isPressed =
            _pressedIndex == index &&
            _videoController != null &&
            _videoController!.value.isInitialized;

        return GestureDetector(
          onLongPress: () => _startVideo(index, true),
          onLongPressEnd: (_) => _stopVideo(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: screenSize.width * 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  isPressed
                      ? AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        )
                      : Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: screenSize.height * 0.35,
        autoPlay: false,
        initialPage: 1,
        enlargeCenterPage: true,
        enlargeFactor: 0.3,
        autoPlayInterval: const Duration(seconds: 3),
        viewportFraction: 0.85,
        onPageChanged: (index, reason) {
          _stopVideo();
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _dotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: images.asMap().entries.map((entry) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentIndex = entry.key;
              _stopVideo();
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _currentIndex == entry.key ? 12.0 : 8.0,
            height: _currentIndex == entry.key ? 12.0 : 8.0,
            margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentIndex == entry.key
                  ? Colors.purpleAccent
                  : Colors.grey[600],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget listV(Size screenSize) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      height: screenSize.height * 0.45,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentIndex = index;
                _stopVideo();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: screenSize.height * 0.2,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget listH(Size screenSize) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      height: screenSize.height * 0.45,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentIndex = index;
                _stopVideo();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: screenSize.width * 0.6, // Wider cards
              height: screenSize.height * 0.35,
              margin: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      width: 400,
                      height: screenSize.height * 2.0,
                      images[index],
                      fit: BoxFit.fill,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    // Title text
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Text(
                        'Show ${index + 1}', // Dynamic title
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
