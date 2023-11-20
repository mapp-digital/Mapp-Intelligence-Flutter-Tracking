import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plugin_mappintelligence/object_tracking_classes.dart';
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Video Player Demo'),
        ),
        body: VideoPlayerScreen());
  }
}

class VideoPlayerScreen extends StatefulWidget {
  //VideoPlayerScreen({Key key}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _previousIsPlaying = false;
  int _seekPosition = 0;
  late ChewieController _chewieController;

  @override
  void initState() {
    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    _controller = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    );
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      aspectRatio: 3 / 2,
      autoPlay: false,
      looping: true,
      // Try playing around with some of these other options:

      // showControls: false,
      // materialProgressColors: ChewieProgressColors(
      //   playedColor: Colors.red,
      //   handleColor: Colors.blue,
      //   backgroundColor: Colors.grey,
      //   bufferedColor: Colors.lightGreen,
      // ),
      // placeholder: Container(
      //   color: Colors.grey,
      // ),
      // autoInitialize: true,
    );

    void trackMedia(String action) {
      var mediaProperties = MediaParameters("TestVideoExample");
      mediaProperties.action = action;
      mediaProperties.position = _controller.value.position.inSeconds;
      mediaProperties.duration = _controller.value.duration.inSeconds;
      mediaProperties.soundVolume = _controller.value.volume * 255.0;
      mediaProperties.soundIsMuted =
          _controller.value.volume == 0.0 ? true : false;

      var mediaEvent = MediaEvent("VideoPlayerController", mediaProperties);
      PluginMappintelligence.trackMedia(mediaEvent);
    }

    _controller.addListener(() {
      if (_controller.value.isPlaying != _previousIsPlaying) {
        if (_controller.value.isPlaying) {
          _previousIsPlaying = true;
          trackMedia("play");
        } else {
          _previousIsPlaying = false;
          trackMedia("stop");
        }
      }

      if ((_controller.value.position.inMilliseconds - _seekPosition).abs() >
          700) {
        trackMedia("seek");
      }
      _seekPosition = _controller.value.position.inMilliseconds;
    });

    // Initialize the controller and store the Future for later use.
    Future<void> _initializeVideoPlayerFuture = _controller.initialize();

    // Use the controller to loop the video.
    _controller.setLooping(true);

    super.initState();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a FutureBuilder to display a loading spinner while waiting for the
      // VideoPlayerController to finish initializing.
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Chewie(
                controller: _chewieController,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _chewieController.enterFullScreen();
            },
            child: Text('Fullscreen'),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _chewieController.dispose();
                      _chewieController = ChewieController(
                        videoPlayerController: _controller,
                        aspectRatio: 3 / 2,
                        autoPlay: false,
                        looping: true,
                      );

                      _controller
                        ..initialize().then((_) {
                          setState(() {
                            _controller.seekTo(Duration(seconds: 3));
                            _controller.play();
                          });
                        });
                    });
                  },
                  child: Padding(
                    child: Text("Seek To"),
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
