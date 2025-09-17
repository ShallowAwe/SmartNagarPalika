import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_nagarpalika/Model/alert_model.dart';
import 'package:smart_nagarpalika/provider/alert_service_provider.dart';
import 'package:smart_nagarpalika/provider/auth_provider.dart';

class HorizontalNewscard extends ConsumerStatefulWidget {
  const HorizontalNewscard({super.key});

  @override
  ConsumerState<HorizontalNewscard> createState() => _HorizontalNewscardState();
}

class _HorizontalNewscardState extends ConsumerState<HorizontalNewscard>
    with TickerProviderStateMixin {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      if (authState != null) {
        final String username = authState.username;
        final String password = authState.password;
      }
    });
  }

  void _onScroll() {
    final position = _scrollController.offset;
    const cardWidth = 252.0; // 240 (card width) + 12 (spacing)
    final index = (position / cardWidth).round();

    if (index != _focusedIndex && index >= 0) {
      setState(() {
        _focusedIndex = index;
      });
      _animationController
        ..reset()
        ..forward();
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
    final cardsAsync = ref.watch(alertsProvider);
    final authState = ref.watch(authProvider);

    if (authState == null) {
      return const Center(child: Text("Not authenticated"));
    }

    final username = authState.username;
    final password = authState.password;

    return SizedBox(
      height: 200,
      child: cardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (cards) {
          if (cards.isEmpty) {
            return const Center(child: Text("No alerts available"));
          }

          return ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: cards.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final card = cards[index];
              final isFocused = index == _focusedIndex;

              return _buildNewsCard(card, isFocused, index, username, password);
            },
          );
        },
      ),
    );
  }

  Widget _buildNewsCard(
    Alertmodel card,
    bool isFocused,
    int index,
    String username,
    String password,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.65;
    const cardHeight = 160.0;

    return GestureDetector(
      onTap: () => print('Tapped on news: ${card.title}'),
      child: InkWell(
        onTap: () {
          showDialog(context: context, builder: (context) {
           return  AlertDialog(
                   actions: [
                    Center(child: Text("Soon to be implemmented", style: TextStyle(fontSize: 15 ),)),
                   ],
             );
          },);
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
                _buildCardImage(card.imageUrl!, username, password),
                _buildGradientOverlay(),
                if (isFocused) _buildFocusOverlay(context),
                _buildTypeBadge(card.type, isFocused),
                _buildCardContent(card, isFocused),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardImage(String imageUrl, String username, String password) {
    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.image_not_supported, size: 40)),
      );
    }

    return Positioned.fill(
      child: Image.network(
        imageUrl,
        headers: {
          "Authorization":
              "Basic ${base64Encode(utf8.encode('$username:$password'))}",
        },
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.image_not_supported, size: 40),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
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
    );
  }

  Widget _buildFocusOverlay(BuildContext context) {
    return Positioned.fill(
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
      case 'articles':
        badgeColor = Colors.blue;
        icon = Icons.article;
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

  Widget _buildCardContent(Alertmodel card, bool isFocused) {
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
              card.title,
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
              card.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
