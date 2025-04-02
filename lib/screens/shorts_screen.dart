import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/video.dart';
import '../services/youtube_api_service.dart';
import '../screens/bottom_nav_bar.dart';
import 'dart:math';

class ShortsScreen extends StatefulWidget {
  final String category;
  final VoidCallback? onReelScrolled;

  const ShortsScreen({Key? key, required this.category, this.onReelScrolled}) : super(key: key);

  @override
  _ShortsScreenState createState() => _ShortsScreenState();
}

class _ShortsScreenState extends State<ShortsScreen> {
  final YoutubeApiService _apiService = YoutubeApiService();
  List<Video> videos = [];
  List<YoutubePlayerController> _controllers = [];
  bool isLoading = true;
  String nextPageToken = "";
  int currentIndex = 0;
  bool isFetchingMore = false;
  final PageController _pageController = PageController();
  int reelsScrolledToday = 0;
  int preloadCount = 3;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _fetchReelsScrolledCount();
    _fetchVideos(refreshFeed: true);
    _pageController.addListener(_handlePageChange);
  }

  Future<void> _fetchReelsScrolledCount() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        setState(() {
          reelsScrolledToday = snapshot['reelsScrolled'] ?? 0;
        });
      }
    } catch (e) {
      print("Error fetching reels count: $e");
    }
  }

  Future<void> _fetchVideos({bool refreshFeed = false}) async {
    if (isFetchingMore) return;
    setState(() => isFetchingMore = true);

    try {
      final result = await _apiService.fetchVideos(widget.category, nextPageToken: refreshFeed ? "" : nextPageToken);
      List<Video> newVideos = result.videos;

      if (refreshFeed) {
        newVideos.shuffle(_random);
      }

      if (newVideos.isNotEmpty) {
        List<YoutubePlayerController> newControllers = newVideos.map((video) {
          var controller = YoutubePlayerController.fromVideoId(
            videoId: video.id,
            autoPlay: false,
            params: YoutubePlayerParams(showFullscreenButton: true, mute: false),
          );

          controller.listen((event) {
            if (controller.value.playerState == PlayerState.ended) {
              _autoScroll();
            }
          });

          return controller;
        }).toList();

        setState(() {
          nextPageToken = result.nextPageToken;
          videos = refreshFeed ? newVideos : [...videos, ...newVideos];
          _controllers = refreshFeed ? newControllers : [..._controllers, ...newControllers];
          isLoading = false;
          isFetchingMore = false;
        });
      }
    } catch (error) {
      print("Error fetching videos: $error");
      setState(() => isFetchingMore = false);
    }
  }

  void _handlePageChange() {
    int newIndex = _pageController.page?.round() ?? currentIndex;
    if (newIndex != currentIndex && newIndex < videos.length) {
      _controllers[currentIndex].pauseVideo();

      setState(() {
        currentIndex = newIndex;
        reelsScrolledToday++;
      });

      _updateReelsScrolledInFirestore();
      widget.onReelScrolled?.call();

      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          _controllers[currentIndex].playVideo();
        }
      });

      if (currentIndex + preloadCount >= videos.length) {
        _fetchVideos();
      }
    }
  }

  Future<void> _updateReelsScrolledInFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'reelsScrolled': reelsScrolledToday},
        SetOptions(merge: true),
      );
    } catch (e) {
      print("Error updating reels count: $e");
    }
  }

  void _autoScroll() {
    if (currentIndex + 1 < videos.length) {
      _pageController.animateToPage(
        currentIndex + 1,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.close();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.red))
                : PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: YoutubePlayer(controller: _controllers[index]),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          BottomNavBar(
            reelsScrolledToday: reelsScrolledToday,
            isShortsScreen: true,
            onAutoScroll: _autoScroll,
          ),
        ],
      ),
    );
  }
}
