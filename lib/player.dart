import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Stateful widget to fetch and then display video content.
class PlayerWidget extends StatefulWidget {
  final String mini;
  const PlayerWidget(this.mini, {super.key});

  @override
  _PlayerWidgetState createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  initializeController() {
    _videoPlayerController = VideoPlayerController.network(
      widget.mini,
      httpHeaders: {'User-Agent': userAgent},
    )..initialize().then((_) {
        setState(() {
          _videoPlayerController.play();
        }); //here you could use Provider or any other state management approach. I use bloc
      });
  }

  String userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36';

  @override
  void initState() {
    super.initState();
    initializeController();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_videoPlayerController.value.isPlaying) {
          _videoPlayerController.pause();
          _confirmExit();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: _videoPlayerController.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _videoPlayerController.value.aspectRatio,
                  child: VideoPlayer(_videoPlayerController),
                )
              : SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white.withOpacity(.6),
                  ),
                ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _videoPlayerController.value.isPlaying
                  ? _videoPlayerController.pause()
                  : _videoPlayerController.play();
            });
          },
          child: Icon(
            _videoPlayerController.value.isPlaying
                ? Icons.pause
                : Icons.play_arrow,
          ),
        ),
      ),
    );
  }

  _confirmExit() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(days: 1),
        content:
            Text("Nós pausamos o video. Deseja deixar de reproduzir o filme?"),
        action: SnackBarAction(
          label: "Sim",
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        showCloseIcon: true,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
  }
}
