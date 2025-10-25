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
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Trust Tier $trustTier',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: const Color(0xFF4CAF50),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}