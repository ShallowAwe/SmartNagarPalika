import 'package:flutter/material.dart';
import 'package:smart_nagarpalika/Data/dummyCardData.dart';

class Horizantalnewscard extends StatefulWidget {
  const Horizantalnewscard({super.key});

  @override
  State<Horizantalnewscard> createState() => _HorizantalnewscardState();
}

class _HorizantalnewscardState extends State<Horizantalnewscard>
    with TickerProviderStateMixin {
  final List<Map<String, String>> cards = dummyCardData;
  final ScrollController _scrollController = ScrollController();
  int _focusedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final position = _scrollController.offset;
    final cardWidth = 252.0; // 240 (card width) + 12 (spacing)
    final index = (position / cardWidth).round();

    if (index != _focusedIndex && index >= 0 && index < cards.length) {
      setState(() {
        _focusedIndex = index;
      });
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200, // Increased height to accommodate all elements properly
      child: Column(
        children: [
          // News cards
          Expanded(
            flex: 4, // Give more space to the cards
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: cards.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final card = cards[index];
                final isFocused = index == _focusedIndex;

                return _buildNewsCard(card, isFocused, index);
              },
            ),
          ),
          // Page indicator
          // if (cards.length > 1)
          //   Expanded(
          //     flex: 1, // Give less space to the indicator
          //     child: Padding(
          //       padding: const EdgeInsets.symmetric(vertical: 8),
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: List.generate(
          //           cards.length,
          //           (index) => AnimatedContainer(
          //             duration: const Duration(milliseconds: 300),
          //             margin: const EdgeInsets.symmetric(horizontal: 2),
          //             width: index == _focusedIndex ? 20 : 8,
          //             height: 8,
          //             decoration: BoxDecoration(
          //               color: index == _focusedIndex
          //                   ? Theme.of(context).primaryColor
          //                   : Colors.grey.withAlpha(76),
          //               borderRadius: BorderRadius.circular(4),
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(Map<String, String> card, bool isFocused, int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.65; // 65% of screen width
    final cardHeight = 160.0; // Fixed height for consistency

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to news detail
        print('Tapped on news: ${card['title']}');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: cardWidth,
        height: cardHeight,
        transform: Matrix4.identity()..scale(isFocused ? 1.05 : 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: isFocused
              ? Border.all(color: Theme.of(context).primaryColor, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
          boxShadow: [
            BoxShadow(
              color: isFocused
                  ? Theme.of(context).primaryColor.withAlpha(76)
                  : Colors.black.withAlpha(25),
              blurRadius: isFocused ? 15 : 8,
              spreadRadius: isFocused ? 2 : 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              // Image with loading and error states
              _buildCardImage(card['image']!),

              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withAlpha(179),
                        Colors.transparent,
                        Colors.black.withAlpha(76),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // Focus overlay
              if (isFocused)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor.withAlpha(51),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

              // Type badge
              _buildTypeBadge(card['type']!, isFocused),

              // Content
              _buildCardContent(card, isFocused),

              // Play button for video content (if applicable)
              if (card['type'] == 'Video') _buildPlayButton(isFocused),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardImage(String imageUrl) {
    return Positioned.fill(
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  size: 40,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 8),
                Text(
                  'Image not available',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeBadge(String type, bool isFocused) {
    Color badgeColor;
    IconData? icon;

    switch (type.toLowerCase()) {
      case 'alerts':
        badgeColor = Colors.red;
        icon = Icons.warning;
        break;
      case 'news':
        badgeColor = Colors.blue;
        icon = Icons.article;
        break;
      case 'video':
        badgeColor = Colors.purple;
        icon = Icons.video_library;
        break;
      default:
        badgeColor = Colors.green;
        icon = Icons.info;
    }

    return Positioned(
      top: 12,
      right: 12,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: badgeColor,
          borderRadius: BorderRadius.circular(20),
          border: isFocused ? Border.all(color: Colors.white, width: 1) : null,
          boxShadow: isFocused
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(76),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: Colors.white),
              const SizedBox(width: 4),
            ],
            Text(
              type,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isFocused ? FontWeight.w800 : FontWeight.w600,
                fontSize: isFocused ? 11 : 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent(Map<String, String> card, bool isFocused) {
    return Positioned(
      bottom: 12,
      left: 12,
      right: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              color: Colors.white,
              fontWeight: isFocused ? FontWeight.w700 : FontWeight.w600,
              fontSize: isFocused ? 16 : 15,
              height: 1.2,
              shadows: [
                Shadow(
                  color: Colors.black.withAlpha(204),
                  offset: const Offset(1, 1),
                  blurRadius: 3,
                ),
              ],
            ),
            child: Text(
              card['title']!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              color: Colors.white.withAlpha(230),
              fontWeight: isFocused ? FontWeight.w500 : FontWeight.w400,
              fontSize: isFocused ? 13 : 12,
              height: 1.3,
              shadows: [
                Shadow(
                  color: Colors.black.withAlpha(153),
                  offset: const Offset(0.5, 0.5),
                  blurRadius: 2,
                ),
              ],
            ),
            child: Text(
              card['desc']!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton(bool isFocused) {
    return Positioned(
      top: 50,
      left: 50,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isFocused ? 60 : 50,
        height: isFocused ? 60 : 50,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(230),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(76),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.play_arrow,
          size: isFocused ? 30 : 25,
          color: Colors.black87,
        ),
      ),
    );
  }
}
