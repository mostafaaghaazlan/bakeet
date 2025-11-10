import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Local video assets from assets/videos/
  final List<String> _videoUrls = [
    'assets/videos/v1.mp4',
    'assets/videos/v2.mp4',
    'assets/videos/v3.mp4',
    'assets/videos/v4.mp4',
    'assets/videos/v5.mp4',
    'assets/videos/v6.mp4',
    'assets/videos/v7.mp4',
    'assets/videos/v8.mp4',
    'assets/videos/v9.mp4',
    'assets/videos/video.mp4',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _videoUrls.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          return ReelItem(
            videoUrl: _videoUrls[index],
            isCurrentPage: index == _currentPage,
          );
        },
      ),
    );
  }
}

class ReelItem extends StatefulWidget {
  final String videoUrl;
  final bool isCurrentPage;

  const ReelItem({
    super.key,
    required this.videoUrl,
    required this.isCurrentPage,
  });

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isLiked = false;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    // Using local asset videos
    _controller = VideoPlayerController.asset(widget.videoUrl)
      ..initialize()
          .then((_) {
            if (mounted) {
              setState(() {
                _isInitialized = true;
              });
              if (widget.isCurrentPage) {
                _controller.play();
                _controller.setLooping(true);
              }
            }
          })
          .catchError((error) {
            debugPrint('Error initializing video: $error');
          });
  }

  @override
  void didUpdateWidget(ReelItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrentPage && _isInitialized) {
      _controller.play();
    } else if (!widget.isCurrentPage && _isInitialized) {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video Player
        _isInitialized
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),

        // Right Side Action Buttons (TikTok style)
        Positioned(
          right: 10,
          bottom: 100,
          child: Column(
            children: [
              // Profile Picture with Follow Button
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      image: const DecorationImage(
                        image: NetworkImage('https://i.pravatar.cc/150?img=3'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -5,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isFollowing = !_isFollowing;
                        });
                      },
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: _isFollowing ? Colors.grey : Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isFollowing ? Icons.check : Icons.add,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Like Button
              _buildActionButton(
                icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                label: '125.3K',
                color: _isLiked ? Colors.red : Colors.white,
                onTap: () {
                  setState(() {
                    _isLiked = !_isLiked;
                  });
                },
              ),
              const SizedBox(height: 25),

              // Comment Button
              _buildActionButton(
                icon: Icons.comment,
                label: '1,234',
                onTap: () {
                  // Visual only - no action
                },
              ),
              const SizedBox(height: 25),

              // Share Button
              _buildActionButton(
                icon: Icons.share,
                label: 'Share',
                onTap: () {
                  // Visual only - no action
                },
              ),
              const SizedBox(height: 25),

              // More Options
              _buildActionButton(
                icon: Icons.more_vert,
                label: '',
                onTap: () {
                  // Visual only - no action
                },
              ),
            ],
          ),
        ),

        // Bottom User Info and Caption
        Positioned(
          left: 15,
          right: 80,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username
              Row(
                children: [
                  const Text(
                    '@username',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isFollowing = !_isFollowing;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _isFollowing ? 'Following' : 'Follow',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Caption
              const Text(
                'This is an amazing video! 🔥 Check out this incredible content #viral #trending',
                style: TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Audio/Music Info
              Row(
                children: [
                  const Icon(Icons.music_note, color: Colors.white, size: 16),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Original Audio - Artist Name',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Play/Pause Icon Indicator
        if (_isInitialized && !_controller.value.isPlaying)
          Center(
            child: Icon(
              Icons.play_arrow,
              size: 80,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
