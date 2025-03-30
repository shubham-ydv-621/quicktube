import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../models/video.dart';
import '../services/youtube_api_service.dart';

class ShortsScreen extends StatefulWidget {
  final String category;
  const ShortsScreen({Key? key, required this.category}) : super(key: key);

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
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _fetchVideos();
    _pageController.addListener(_handlePageChange);
  }

  Future<void> _fetchVideos() async {
    if (isFetchingMore) return;
    setState(() => isFetchingMore = true);

    try {
      final result = await _apiService.fetchVideos(widget.category, nextPageToken: nextPageToken);
      
      setState(() {
        nextPageToken = result.nextPageToken;
        for (var video in result.videos) {
          videos.add(video);
          _controllers.add(
            YoutubePlayerController.fromVideoId(
              videoId: video.id,
              autoPlay: false,
              params: YoutubePlayerParams(showFullscreenButton: true, mute: false),
            ),
          );
        }
        isLoading = false;
        isFetchingMore = false;
      });

      if (_controllers.isNotEmpty && currentIndex == 0) {
        _controllers.first.playVideo();
      }
    } catch (error) {
      print("Error fetching videos: $error");
      setState(() => isFetchingMore = false);
    }
  }

  void _handlePageChange() {
    int newIndex = _pageController.page?.round() ?? currentIndex;
    if (newIndex != currentIndex && newIndex < _controllers.length) {
      _controllers[currentIndex].pauseVideo();
      setState(() => currentIndex = newIndex);
      _controllers[currentIndex].playVideo();

      if (currentIndex >= videos.length - 2) {
        _fetchVideos();
      }
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
      body: isLoading
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
                    Positioned(
                      bottom: 40,
                      left: 16,
                      right: 16,
                      child: Text(
                        videos[index].title,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}