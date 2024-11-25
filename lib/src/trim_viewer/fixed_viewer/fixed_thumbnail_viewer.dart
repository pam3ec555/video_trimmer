import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:transparent_image/transparent_image.dart';

class FixedThumbnailViewer extends StatefulWidget {
  final File videoFile;
  final int videoDuration;
  final double thumbnailHeight;
  final BoxFit fit;
  final int numberOfThumbnails;
  final VoidCallback onThumbnailLoadingComplete;
  final int quality;

  /// For showing the thumbnails generated from the video,
  /// like a frame by frame preview
  const FixedThumbnailViewer({
    Key? key,
    required this.videoFile,
    required this.videoDuration,
    required this.thumbnailHeight,
    required this.numberOfThumbnails,
    required this.fit,
    required this.onThumbnailLoadingComplete,
    this.quality = 75,
  }) : super(key: key);

  @override
  State<FixedThumbnailViewer> createState() => _FixedThumbnailViewerState();
}

class _FixedThumbnailViewerState extends State<FixedThumbnailViewer> {
  Uint8List? _firstBytes;

  Stream<List<Uint8List?>> generateThumbnail() async* {
    final String videoPath = widget.videoFile.path;
    double eachPart = widget.videoDuration / widget.numberOfThumbnails;
    List<Uint8List?> byteList = [];
    // the cache of last thumbnail
    Uint8List? lastBytes;
    for (int i = 1; i <= widget.numberOfThumbnails; i++) {
      Uint8List? bytes;
      try {
        bytes = await VideoThumbnail.thumbnailData(
          video: videoPath,
          imageFormat: ImageFormat.JPEG,
          timeMs: (eachPart * i).toInt(),
          quality: widget.quality,
        );
      } catch (e) {
        debugPrint('ERROR: Couldn\'t generate thumbnails: $e');
      }
      // if current thumbnail is null use the last thumbnail
      if (bytes != null) {
        lastBytes = bytes;
      } else {
        bytes = lastBytes;
      }
      _firstBytes ??= bytes;
      byteList.add(bytes);
      if (byteList.length == widget.numberOfThumbnails) {
        widget.onThumbnailLoadingComplete();
      }
      yield byteList;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Uint8List?>>(
      stream: generateThumbnail(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Uint8List?> imageBytes = snapshot.data!;
          final firstImageBytes = _firstBytes;
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              widget.numberOfThumbnails,
              (index) => SizedBox(
                height: widget.thumbnailHeight,
                width: widget.thumbnailHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (firstImageBytes != null)
                      Opacity(
                        opacity: 0.2,
                        child: Image.memory(
                          firstImageBytes,
                          fit: widget.fit,
                        ),
                      ),
                    index < imageBytes.length && imageBytes[index] != null
                        ? FadeInImage(
                            placeholder: MemoryImage(kTransparentImage),
                            image: MemoryImage(imageBytes[index]!),
                            fit: widget.fit,
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Container(
            color: Colors.grey[900],
            height: widget.thumbnailHeight,
            width: double.maxFinite,
          );
        }
      },
    );
  }
}
