import 'package:flutter/material.dart';

// Custom widget for the profile bar at the bottom
class ProfileBar extends StatelessWidget {
  const ProfileBar({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: const Color(0xFF4A7C59).withOpacity(0.4),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage('[https://i.pravatar.cc/150?img=12](https://i.pravatar.cc/150?img=12)'),
              onBackgroundImageError: null,
              backgroundColor: Colors.grey,
            ),
            const SizedBox(width: 15),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UserName',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '25 dashcards criados\n97 questões de provas',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/edit_profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF132F2C).withOpacity(0.8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('EDITAR\nPERFIL', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
            )
          ],
        ),
      ),
    );
  }
}