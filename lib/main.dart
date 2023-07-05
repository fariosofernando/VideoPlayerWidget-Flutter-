import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VideoWidget('assets/trailer.mp4')));
}

class VideoWidget extends StatefulWidget {
  final String source;
  final Color playerBackgroundColor;
  const VideoWidget(this.source,
      {super.key, this.playerBackgroundColor = Colors.black});

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _videoPlayerController;
  bool _showController = false;
  double _sliderValue = 0.0;
  bool _isDraggingSlider = false;

  @override
  void initState() {
    super.initState();
    initializeController();
  }

  void initializeController() {
    _videoPlayerController = VideoPlayerController.asset(
      widget.source,
      videoPlayerOptions: VideoPlayerOptions(
        allowBackgroundPlayback: false,
        mixWithOthers: false,
      ),
    )..initialize().then((_) {
        setState(() {
          _videoPlayerController.play();
          _videoPlayerController.addListener(_videoPlayerListener);
        });
      });
  }

  void _videoPlayerListener() {
    if (_videoPlayerController.value.isPlaying) {
      if (!_isDraggingSlider) {
        setState(() {
          _sliderValue = _videoPlayerController.value.position.inMilliseconds /
              _videoPlayerController.value.duration.inMilliseconds;
        });
      }
    }
  }

  Future<void> _showControllers() async {
    if (_videoPlayerController.value.isPlaying) {
      setState(() {
        _showController = !_showController;
      });
    }

    if (_showController && _videoPlayerController.value.isPlaying) {
      await Future.delayed(const Duration(seconds: 3));
      setState(() {
        _showController = false;
      });
    }
  }

  _playVideo(isPlaying) {
    if (isPlaying) {
      _videoPlayerController.pause();
    } else {
      _videoPlayerController.play();
    }
    setState(() {});
  }

  void _onSliderValueChanged(double value) {
    setState(() {
      _sliderValue = value;
    });

    final Duration newPosition = _videoPlayerController.value.duration * value;
    _videoPlayerController.seekTo(newPosition);
  }

  void _onSliderDragStart() {
    setState(() {
      _isDraggingSlider = true;
    });
  }

  void _onSliderDragEnd() {
    setState(() {
      _isDraggingSlider = false;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.playerBackgroundColor,
      body: Stack(
        children: [
          Center(
            child: _videoPlayerController.value.isInitialized
                ? SizedBox(
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () => _showControllers(),
                            child: AspectRatio(
                              aspectRatio:
                                  _videoPlayerController.value.aspectRatio,
                              child: Stack(
                                children: [
                                  VideoPlayer(_videoPlayerController),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Visibility(
                                      visible: !_videoPlayerController
                                              .value.isPlaying ||
                                          _showController,
                                      child: FloatingActionButton(
                                        backgroundColor:
                                            Colors.black.withOpacity(.4),
                                        onPressed: () => _playVideo(
                                            _videoPlayerController
                                                .value.isPlaying),
                                        child: Icon(
                                          _videoPlayerController.value.isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Visibility(
                                      visible: !_videoPlayerController
                                              .value.isPlaying ||
                                          _showController,
                                      child: Container(
                                        height: 35,
                                        margin: const EdgeInsets.only(
                                            bottom: 35, left: 10, right: 10),
                                        child: Stack(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 35,
                                                right: 35,
                                                bottom: 15,
                                              ),
                                              child: Slider(
                                                thumbColor: Colors.white,
                                                activeColor: Colors.white
                                                    .withOpacity(.4),
                                                inactiveColor: Colors.white
                                                    .withOpacity(.2),
                                                value: _sliderValue,
                                                onChanged: _isDraggingSlider
                                                    ? null
                                                    : _onSliderValueChanged,
                                                onChangeStart: (_) =>
                                                    _onSliderDragStart(),
                                                onChangeEnd: (_) =>
                                                    _onSliderDragEnd(),
                                              ),
                                            ),
                                            Positioned(
                                              left:
                                                  12, // Posição do Text à esquerda
                                              child: Text(
                                                _formatDuration(
                                                    _videoPlayerController
                                                        .value.position),
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                            Positioned(
                                              right:
                                                  12, // Posição do Text à direita
                                              child: Text(
                                                _formatDuration(
                                                    _videoPlayerController
                                                        .value.duration),
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(
                      color: Colors.white.withOpacity(.6),
                    ),
                  ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SafeArea(
              child: Visibility(
                visible:
                    !_videoPlayerController.value.isPlaying || _showController,
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.removeListener(_videoPlayerListener);
    _videoPlayerController.dispose();
  }
}
