import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class VideoPage extends StatefulWidget {
  final String filePath;

  const VideoPage({Key? key, required this.filePath}) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController _videoPlayerController;

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future _initVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.file(File(widget.filePath));
    await _videoPlayerController.initialize();
    await _videoPlayerController.setLooping(true);
    await _videoPlayerController.play();
  }

  @override
  Widget build(BuildContext context) {
    // String twoDigits(int n) => n.toString().padLeft(2, '0');
    // final hours = twoDigits(_videoPlayerController.value.duration.inHours);
    // final minutes = twoDigits(
    //     _videoPlayerController.value.duration.inMinutes.remainder(60));
    // final seconds = twoDigits(
    //     _videoPlayerController.value.duration.inSeconds.remainder(60));
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          child: Text(
            'Done',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () async {
            await GallerySaver.saveVideo(widget.filePath);
            File(widget.filePath).deleteSync();
            print('My Movie');
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text('My Movie'),
        elevation: 0,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.help_outline_outlined),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: FutureBuilder(
        future: _initVideoPlayer(),
        builder: (context, state) {
          if (state.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            // print(_videoPlayerController.value.duration.inSeconds.toString());
            return Stack(
              children: [
                VideoPlayer(_videoPlayerController),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      // print('$hours:$minutes:$seconds');

                      print(_videoPlayerController.value.duration.inSeconds
                          .toString());

                      if (_videoPlayerController.value.duration.inSeconds <
                          30) {
                        print('object');
                      } else {
                        print('noop');
                      }
                    },
                    child: Text('10 Seconds'),
                  ),
                )
              ],
            );
          }
        },
      ),
    );
  }
}
