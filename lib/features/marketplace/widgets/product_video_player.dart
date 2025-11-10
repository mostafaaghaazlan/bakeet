import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:bakeet/core/constant/app_colors/app_colors.dart';

/// A Reels-style video player for product videos
/// Automatically plays when visible and pauses when not visible
class ProductVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool showControls;
  final BorderRadius? borderRadius;

  const ProductVideoPlayer({
    super.key,
    required this.videoUrl,
    this.autoPlay = true,
    this.showControls = true,
    this.borderRadius,
  });

  @override
  State<ProductVideoPlayer> createState() => _ProductVideoPlayerState();
}

class _ProductVideoPlayerState extends State<ProductVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showControls = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      // Check if it's a network URL or asset
      if (widget.videoUrl.startsWith('http')) {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
        );
      } else {
        _controller = VideoPlayerController.asset(widget.videoUrl);
      }

      await _controller.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });

        // Set looping for Reels-style continuous play
        _controller.setLooping(true);

        // Auto-play if enabled
        if (widget.autoPlay) {
          _controller.play();
        }
      }
    } catch (e) {
      print('Error initializing video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    // Auto-play when 50% visible, pause when less than 50% visible
    if (info.visibleFraction > 0.5) {
      if (!_controller.value.isPlaying && widget.autoPlay) {
        _controller.play();
      }
    } else {
      if (_controller.value.isPlaying) {
        _controller.pause();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('video-${widget.videoUrl}'),
      onVisibilityChanged: _handleVisibilityChanged,
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(16.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video player or loading/error state
            if (_hasError)
              _buildErrorState()
            else if (!_isInitialized)
              _buildLoadingState()
            else
              GestureDetector(
                onTap: () {
                  if (widget.showControls) {
                    setState(() {
                      _showControls = !_showControls;
                    });
                    // Auto-hide controls after 3 seconds
                    Future.delayed(const Duration(seconds: 3), () {
                      if (mounted) {
                        setState(() {
                          _showControls = false;
                        });
                      }
                    });
                  }
                  _togglePlayPause();
                },
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),

            // Play/Pause overlay
            if (_isInitialized && !_controller.value.isPlaying)
              Center(
                child: Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.white,
                    size: 40.sp,
                  ),
                ),
              ),

            // Video indicator badge (Reels-style)
            Positioned(
              top: 8.h,
              left: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.play_circle_filled_rounded,
                      color: AppColors.white,
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Video',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Progress indicator (bottom)
            if (_isInitialized)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: AppColors.primary,
                    bufferedColor: AppColors.neutral300,
                    backgroundColor: AppColors.neutral200.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),

            // Mute/Unmute button (optional, if controls are shown)
            if (_isInitialized && _showControls && widget.showControls)
              Positioned(
                top: 8.h,
                right: 8.w,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _controller.setVolume(
                        _controller.value.volume > 0 ? 0.0 : 1.0,
                      );
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _controller.value.volume > 0
                          ? Icons.volume_up_rounded
                          : Icons.volume_off_rounded,
                      color: AppColors.white,
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: AppColors.neutral200,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: AppColors.neutral200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.danger,
              size: 40.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              'Failed to load video',
              style: TextStyle(color: AppColors.neutral600, fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }
}
