import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PeripherialScreen extends StatefulWidget {
  const PeripherialScreen({super.key});

  @override
  State<PeripherialScreen> createState() => _PeripherialScreenState();
}

class _PeripherialScreenState extends State<PeripherialScreen> {
  File? _imageFile;
  FlutterSoundRecorder _flutterSoundRecorder = FlutterSoundRecorder();
  String? _audioPath;
  bool _isRecording = false;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _flutterSoundRecorder.openRecorder();
  }

  @override
  void dispose() {
    super.dispose();
    _flutterSoundRecorder.closeRecorder();
  }

  // Tomar foto
  Future<void> _takeImage() async {
    final dynamic pickedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  Future<void> _startRecording() async {
    if (await Permission.microphone.request().isGranted) {
      Directory? appDocDirectory = await getApplicationDocumentsDirectory();
      String path = appDocDirectory.path + "/recording.aac";

      await _flutterSoundRecorder.startRecorder(
        toFile: path,
        codec: Codec.aacADTS,
      );

      setState(() {
        _audioPath = path;
        _isRecording = true;
      });
    }
  }

  Future<void> _stopRecording() async {
    await _flutterSoundRecorder.stopRecorder();
    setState(() {
      _isRecording = false;
    });
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _filePath = result.files.single.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Periféricos"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_imageFile != null) Image.file(_imageFile!),
            ElevatedButton(
              onPressed: _takeImage,
              child: Text("Tomar foto"),
            ),
            if (_imageFile != null) Text(_imageFile!.path), // Condicional aquí
          ],
        ),
      ),
    );
  }
}
