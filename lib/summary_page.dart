import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:youtube_recipe/firebase_options.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'oauth_sign_in.dart';


class SummaryPage extends StatefulWidget {

  final String videoId;

  SummaryPage({required this.videoId});

  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _messages = [];
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      params: YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }



  Future<void> _sendMessage(String text) async {
    final String endpoint = 'https://api.openai.iniad.org/api/v1/chat/completions';  // Replace with your endpoint
    final String apiKey = 'cd43qN-dzvcHSlK8aLf0v0xzRymCG09hHYSdBAmcNGOD1Y_-Wqt49APDXsytEeQS_5Z_Fkj1y19fNf7PdaujI4Q';  // Replace with your API key

    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'system',
          'content': 'You are a helpful assistant.'
        },
        {
          'role': 'user',
          'content': text,
        },
      ],
    });

    final response = await http.post(
      Uri.parse(endpoint),
      headers: headers,
      body: body,
    );

    if (response.statusCode != 200) {
      print('Error: ${response.body}');
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data != null &&
          data.containsKey('choices') &&
          data['choices'] is List &&
          data['choices'].isNotEmpty &&
          data['choices'][0] is Map &&
          data['choices'][0].containsKey('message') &&
          data['choices'][0]['message'] is Map &&
          data['choices'][0]['message'].containsKey('content') &&
          data['choices'][0]['message']['content'] is String) {
        final String reply = data['choices'][0]['message']['content'].trim();
        print('Decoded text: $reply');  // コンソールにデコードされたテキストを出力
        setState(() {
          _messages.add('User: $text');
          _messages.add('GPT: $reply');
        });
      } else {
        print('Unexpected response format');
      }
    } else {
      print('Error: ${response.body}');
    }
  }



  Future<void> getAndSaveCaptions() async {
    final token = await Auth.signInWithOAuth(context);  // <--- Get token using the new method
    final String YOUTUBE_APIKEY = "AIzaSyA8OXpQMoeDgbb7nkwX4mDpjeCh4UmQkOQ";

    // まず字幕トラックのリストを取得
    final captionListUrl = 'https://www.googleapis.com/youtube/v3/captions?videoId=${widget.videoId}&key=$YOUTUBE_APIKEY';
    final captionListResponse = await http.get(
      Uri.parse(captionListUrl),
      headers: {'Authorization': 'Bearer $token'},

    );


    final Map<String, dynamic> captionListData = jsonDecode(captionListResponse.body);
    if (captionListData['items'] == null || captionListData['items'].isEmpty) {
      print('No captions found');
      return;
    }

    // 最初の字幕トラックのIDを取得
    final String captionId = captionListData['items'][0]['id'];

    // 字幕トラックのIDを使用して字幕データをダウンロード
    final captionDownloadUrl = 'https://www.googleapis.com/youtube/v3/captions/$captionId?tfmt=srv3&key=$YOUTUBE_APIKEY';
    final captionDownloadResponse = await http.get(
      Uri.parse(captionDownloadUrl),
      headers: {'Authorization': 'Bearer $token'},

    );

    // 字幕データをFirestoreに保存
    saveCaptionsToFirestore(captionDownloadResponse.body);
  }

  void saveCaptionsToFirestore(String captions) {
    final CollectionReference captionsCollection = FirebaseFirestore.instance.collection('captions');
    captionsCollection.add({'captions': captions}).then((value) {
      print("Captions saved to Firestore");
    }).catchError((error) {
      print("Failed to save captions: $error");
    });
  }






  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Summary'),
      ),
      body: Column(
        children: [
          YoutubePlayer(
            controller: _controller,
            aspectRatio: 16 / 9,
          ),
      ElevatedButton(
        onPressed: getAndSaveCaptions,
        child: Text('Fetch and Save Captions'),
      ),

          Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.videoId,   // videoId を使用
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                //Text(widget.video.channelTitle),
                SizedBox(height: 8.0),
                //Text(widget.video.url),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final text = _textController.text;
                    _textController.clear();
                    _sendMessage(text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


