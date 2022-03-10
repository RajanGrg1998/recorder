// Counting pointers (number of user fingers on screen)
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

int pointers = 0;

double currentScale = 1.0;
double baseScale = 1.0;

void handleScaleStart(ScaleStartDetails details) {
  baseScale = currentScale;
}

// loading

bool isLoading = true;
bool isRecordingInProgress = false;

// flashmode
FlashMode? currentFlashMode;
bool onFlashClick = true;

//rear camera
bool isRearCameraSelected = true;

final resolutionPresets = ResolutionPreset.values;

ResolutionPreset currentResolutionPreset = ResolutionPreset.high;

// zoom

double minAvailableExposureOffset = 0.0;
double maxAvailableExposureOffset = 0.0;
double minAvailableZoom = 1.0;
double maxAvailableZoom = 1.0;
double currentZoomLevel = 1.0;

Future<void> handleScaleUpdate(
    ScaleUpdateDetails details, CameraController _cameraController) async {
  // When there are not exactly two fingers on screen don't scale
  if (pointers != 2) {
    return;
  }

  currentScale =
      (baseScale * details.scale).clamp(minAvailableZoom, maxAvailableZoom);

  await _cameraController.setZoomLevel(currentScale);
}
