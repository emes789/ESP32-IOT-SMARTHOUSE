import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:video_player/video_player.dart';

/*
 * Nowy panel (zakładka) do wyświetlania strumienia wideo z ESP32-CAM.
 * iOS używa video_player, Android/Desktop używa flutter_vlc_player
 * (Zadanie 4)
 */
class CameraTab extends StatefulWidget {
  const CameraTab({super.key});

  @override
  State<CameraTab> createState() => _CameraTabState();
}

class _CameraTabState extends State<CameraTab> {
  // TODO: Ten adres IP powinien być dynamicznie pobierany po provisioningu BLE
  // Na razie jest to placeholder.
  final String _videoStreamUrl = 'http://192.168.1.10:81/stream';
  
  // VLC Player dla Android/Desktop
  VlcPlayerController? _vlcController;
  
  // Video Player dla iOS
  VideoPlayerController? _videoController;
  
  bool _isLoading = true;
  bool _hasError = false;
  
  // Sprawdź czy to iOS
  bool get _isIOS => !kIsWeb && Platform.isIOS;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    if (_isIOS) {
      // iOS używa video_player
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(_videoStreamUrl),
      );
      
      _videoController!.initialize().then((_) {
        setState(() {
          _isLoading = false;
        });
        _videoController!.play();
      }).catchError((error) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      });
    } else {
      // Android/Desktop używa VLC
      _vlcController = VlcPlayerController.network(
        _videoStreamUrl,
        hwAcc: HwAcc.full,
        autoPlay: true,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions([
            VlcAdvancedOptions.networkCaching(300),
          ]),
          video: VlcVideoOptions([
            VlcVideoOptions.dropLateFrames(true),
            VlcVideoOptions.skipFrames(true),
          ]),
          rtp: VlcRtpOptions([
            VlcRtpOptions.rtpOverRtsp(true),
          ]),
        ),
      );

      _vlcController!.addListener(_checkLoading);
    }
  }

  void _checkLoading() {
    if (_vlcController != null && 
        _vlcController!.value.isPlaying && 
        _isLoading) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() async {
    super.dispose();
    
    if (_vlcController != null) {
      _vlcController!.removeListener(_checkLoading);
      await _vlcController!.stopRendererScanning();
      await _vlcController!.dispose();
    }
    
    if (_videoController != null) {
      await _videoController!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Podgląd z Kamery'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_isIOS)
              _buildIOSPlayer()
            else
              _buildVLCPlayer(),
              
            if (_isLoading)
              const CircularProgressIndicator(),
              
            if (_hasError || (_vlcController?.value.hasError ?? false))
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Nie można połączyć ze strumieniem wideo.\nUpewnij się, że jesteś w tej samej sieci Wi-Fi co kamera.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white, 
                    backgroundColor: Colors.black54,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildIOSPlayer() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return AspectRatio(
      aspectRatio: _videoController!.value.aspectRatio,
      child: VideoPlayer(_videoController!),
    );
  }
  
  Widget _buildVLCPlayer() {
    if (_vlcController == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return VlcPlayer(
      controller: _vlcController!,
      aspectRatio: 16 / 9,
      placeholder: const Center(child: CircularProgressIndicator()),
    );
  }
}