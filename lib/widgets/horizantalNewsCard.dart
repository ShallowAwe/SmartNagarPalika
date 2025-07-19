import 'package:flutter/material.dart';
import 'package:smart_nagarpalika/Data/dummyCardData.dart';

class Horizantalnewscard extends StatefulWidget {
  const Horizantalnewscard({super.key});

  @override
  State<Horizantalnewscard> createState() => _HorizantalnewscardState();
}

class _HorizantalnewscardState extends State<Horizantalnewscard> {

  final List<Map<String, String>>  cards =  dummyCardData;
  @override
  Widget build(BuildContext context) {
     return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final card = cards[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Image.network(
                  card['image']!,
                  width: 240,
                  height: 160,
                  fit: BoxFit.cover,
                ),
                Container(
                  width: 240,
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withAlpha(156),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: card['type'] == 'Alerts'
                          ? Colors.red
                          : Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      card['type']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Text(
                    '${card['title']!}\n${card['desc']!}',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
  