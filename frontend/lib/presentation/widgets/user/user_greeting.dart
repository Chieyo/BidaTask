import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserGreeting extends StatelessWidget {
  final String username;
  final String trustTier;

  const UserGreeting({
    super.key,
    required this.username,
    this.trustTier = '1',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // User avatar
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: Colors.grey),
        ),
        const SizedBox(width: 12),
        // Greeting and trust tier
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, $username!',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Trust Tier $trustTier',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),

          ],
        ),
      ],
    );
  }
}