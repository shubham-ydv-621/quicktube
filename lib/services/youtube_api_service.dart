import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video.dart';

class YoutubeApiService {
  static const String apiKey = 'AIzaSyDChBFO2F58_9_SyY4FBk1m8eYCKJwSTTQ';

  Future<VideoResult> fetchVideos(String category, {String nextPageToken = ""}) async {
    final query = Uri.encodeComponent('$category shorts');
    final url =
        'https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=10&pageToken=$nextPageToken&q=$query&type=video&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final newNextPageToken = data['nextPageToken'] ?? "";

      List<Video> videos = [];
      for (var item in data['items']) {
        if (item['id'] != null && item['id']['videoId'] != null) {
          videos.add(Video.fromJson(item));
        }
      }

      return VideoResult(videos: videos, nextPageToken: newNextPageToken);
    } else {
      throw Exception('Failed to load videos.');
    }
  }
}

class VideoResult {
  final List<Video> videos;
  final String nextPageToken;

  VideoResult({required this.videos, required this.nextPageToken});
}
