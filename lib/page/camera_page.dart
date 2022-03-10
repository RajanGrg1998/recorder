import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../constants.dart';
import '../main.dart';
import '../widgets/timer_widget.dart';
import 'video_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  // controller
  late CameraController _cameraController;

  final TimerController _timerController = TimerController();

// focus
  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    final CameraController cameraController = _cameraController;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  @override
  void initState() {
    _initCamera(cameras[0]);

    super.initState();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  // initializing

  _initCamera(CameraDescription cameraDescription) async {
    try {
      // final cameras = await availableCameras();
      // final front = cameras.firstWhere(
      //     (camera) => camera.lensDirection == CameraLensDirection.back);
      _cameraController = CameraController(
        cameraDescription,
        currentResolutionPreset,
        enableAudio: true,
      );
      currentFlashMode = _cameraController.value.flashMode;
      await _cameraController.initialize();

      await Future.wait([
        _cameraController
            .getMaxZoomLevel()
            .then((value) => maxAvailableZoom = value),
        _cameraController
            .getMinZoomLevel()
            .then((value) => minAvailableZoom = value),
      ]);
      setState(() => isLoading = false);
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }
  }

  // record
  _recordVideo() async {
    final CameraController? cameraController = _cameraController;
    if (_cameraController.value.isRecordingVideo) {
      // A recording has already started, do nothing.
      return;
    }
    try {
      await cameraController!.startVideoRecording();
      await _cameraController.prepareForVideoRecording();
      setState(() {
        isRecordingInProgress = true;
        print(isRecordingInProgress);
      });
    } on CameraException catch (e) {
      print('Error starting to record video: $e');
    }
    // if (!isRecordingInProgress) {
    //   await _cameraController.startVideoRecording();

    //   setState(() => isRecordingInProgress = true);
    // }
  }

  // record
  _stopRecordVideo() async {
    if (isRecordingInProgress) {
      final file = await _cameraController.stopVideoRecording();
      setState(() => isRecordingInProgress = false);
      final route = MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => VideoPage(filePath: file.path),
      );
      Navigator.push(context, route);
    }
  }

  Future<XFile?> stopVideoRecording() async {
    if (!_cameraController.value.isRecordingVideo) {
      // Recording is already is stopped state
      return null;
    }
    try {
      XFile file = await _cameraController.stopVideoRecording();
      setState(() {
        isRecordingInProgress = false;
        print(isRecordingInProgress);
      });
      final route = MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => VideoPage(filePath: file.path),
      );
      Navigator.push(context, route);
      return file;
    } on CameraException catch (e) {
      print('Error stopping video recording: $e');
      return null;
    }
  }

  // pause
  Future<void> pauseVideoRecording() async {
    if (!_cameraController.value.isRecordingVideo) {
      // Video recording is not in progress
      return;
    }
    try {
      await _cameraController.pauseVideoRecording();
    } on CameraException catch (e) {
      print('Error pausing video recording: $e');
    }
  }

// resume
  Future<void> resumeVideoRecording() async {
    if (!_cameraController.value.isRecordingVideo) {
      // No video recording was in progress
      return;
    }
    try {
      await _cameraController.resumeVideoRecording();
    } on CameraException catch (e) {
      print('Error resuming video recording: $e');
    }
  }

  final isDialOpen = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            if (isDialOpen.value) {
              isDialOpen.value = false;
              return false;
            } else {
              return true;
            }
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: DropdownButton<ResolutionPreset>(
                    dropdownColor: Colors.black87,
                    alignment: AlignmentDirectional.centerEnd,
                    underline: Container(),
                    value: currentResolutionPreset,
                    items: [
                      for (ResolutionPreset preset in resolutionPresets)
                        DropdownMenuItem(
                          child: Text(
                            preset.toString().split('.')[1].toUpperCase(),
                            style: TextStyle(color: Colors.white),
                          ),
                          value: preset,
                        )
                    ],
                    onChanged: (value) {
                      setState(() {
                        currentResolutionPreset = value!;
                      });
                      _initCamera(_cameraController.description);
                    },
                    hint: Text("Select item"),
                  ),
                )
              ],
              leading: Row(
                children: [
                  Expanded(
                    child: IconButton(
                      onPressed: () async {
                        if (isRearCameraSelected) {
                          setState(() {
                            currentFlashMode =
                                onFlashClick ? FlashMode.torch : FlashMode.off;
                          });

                          setState(() {
                            onFlashClick = !onFlashClick;
                          });

                          await _cameraController
                              .setFlashMode(currentFlashMode!);
                        }
                      },
                      icon: Icon(
                        onFlashClick ? Icons.flash_off : Icons.flash_on,
                        size: 20,
                        color: onFlashClick ? Colors.white : Colors.yellow,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: IconButton(
                      onPressed: () {
                        _initCamera(
                          cameras[isRearCameraSelected ? 1 : 0],
                        );
                        setState(() {
                          isRearCameraSelected = !isRearCameraSelected;
                        });
                      },
                      icon: Icon(
                        Icons.change_circle_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              title: TimerWideget(timerController: _timerController),
            ),
            body: Center(
              child: CameraPreview(
                _cameraController,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isRecordingInProgress
                              ? Text(
                                  'Stop \n Session',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                )
                              : Text(
                                  'Start \n Session',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),

                          // FloatingActionButton(
                          //   mini: false,
                          //   backgroundColor: Colors.black,
                          //   splashColor: Colors.black,
                          //   onPressed: () {},
                          //   hoverElevation: 1.5,
                          //   shape: StadiumBorder(
                          //       side: BorderSide(color: Colors.white, width: 4)),
                          //   elevation: 1.5,
                          //   child: Icon(
                          //     Icons.circle,
                          //     size: 50,
                          //     color: Colors.red,
                          //   ),
                          // ),
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 8.0, top: 8.0),
                            child: SpeedDial(
                              overlayColor: Colors.transparent,
                              backgroundColor: Colors.black,
                              overlayOpacity: 0, buttonSize: Size(50, 50),
                              openCloseDial: isDialOpen,
                              shape: StadiumBorder(
                                  side: BorderSide(
                                      color: Colors.white, width: 4)),
                              elevation: 1.5,
                              child: Icon(
                                Icons.circle,
                                size: 50,
                                color: Colors.red,
                              ),

                              // icon: Icons.share,
                              children: [
                                SpeedDialChild(
                                    child: Icon(Icons.play_arrow_sharp),
                                    onTap: () {
                                      _recordVideo();
                                      if (!isRecordingInProgress) {
                                        _timerController.startTimer();
                                      }
                                    }),
                                SpeedDialChild(
                                    child: Icon(isRecordingInProgress
                                        ? Icons.abc
                                        : Icons.pause_sharp),
                                    onTap: () async {
                                      if (_cameraController
                                          .value.isRecordingPaused) {
                                        await resumeVideoRecording();
                                      } else {
                                        await pauseVideoRecording();
                                      }
                                    }),
                                SpeedDialChild(
                                    child: Icon(Icons.stop_sharp),
                                    onTap: () {
                                      // _stopRecordVideo();
                                      stopVideoRecording();
                                      if (isRecordingInProgress) {
                                        _timerController.stopTimer();
                                      }
                                    }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 80, right: 25),
                        child: Divider(
                          height: 126,
                          thickness: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Transform.translate(
                          offset: Offset(10, -70),
                          child: Text(
                            'Add Last',
                            style: TextStyle(color: Colors.white),
                          ),
                        )),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Transform.translate(
                        offset: Offset(-15, -6),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CustomTimeButton(label: ':10', onPressed: () {}),
                              CustomTimeButton(
                                  label: ':30',
                                  onPressed: () {
                                    print('object');
                                  }),
                              CustomTimeButton(label: '1:00', onPressed: () {}),
                              CustomTimeButton(label: '3:00', onPressed: () {}),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}

class CustomTimeButton extends StatelessWidget {
  const CustomTimeButton({
    Key? key,
    required this.label,
    this.onPressed,
  }) : super(key: key);
  final String label;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.circle,
          color: Colors.white,
          size: 50,
        ),
        ElevatedButton(
          onPressed: onPressed,
          child: Text(
            label,
            style: TextStyle(color: Colors.black),
          ),
          style: ElevatedButton.styleFrom(
              primary: Colors.white,
              shape: CircleBorder(),
              side: BorderSide(color: Colors.black, width: 2)),
        )
      ],
    );
  }
}
