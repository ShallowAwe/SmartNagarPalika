import 'package:flutter/material.dart';

class TopContainer extends StatelessWidget {
  const TopContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300, 
      width: double.infinity,
      // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        color: Colors.white,
        image:  DecorationImage(
          image: NetworkImage('https://media.assettype.com/freepressjournal/2023-09/f4cad33d-d280-49f4-9279-e488fab84351/PMC_building__2_.jpg?width=1200'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(204),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // /// Left Side: Welcome / Logo
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: const [
          //     Text(
          //       'Smart Nagarpalika',
          //       style: TextStyle(
          //         fontSize: 18,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //     SizedBox(height: 4),
          //     Text(
          //       'Welcome Rudra 👋',
          //       style: TextStyle(
          //         fontSize: 14,
          //         color: Colors.black54,
          //       ),
          //     ),
          //   ],
          // ),

          /// Right Side: Notification Icon
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Notification screen
            },
          ),
        ],
      ),
    );
  }
}
