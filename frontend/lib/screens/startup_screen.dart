import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import 'login_screen.dart';

class StartupScreen extends StatelessWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6354D9), // Precise purple from image
      body: SafeArea(
        child: Stack(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () {
                      // Close or Skip action
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white, size: 28),
                    onPressed: () {
                      // Menu action
                    },
                  ),
                ],
              ),
            ),
            
            // Main Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  // Title Text
                  Text(
                    'What is your\nStartup?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  const Spacer(),
                  // Illustration Image
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.45,
                    child: Center(
                      child: Image.asset(
                        'assets/images/startup_illustration.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback if image fails to load
                          return const Icon(
                            Icons.rocket_launch,
                            size: 200,
                            color: Colors.white70,
                          );
                        },
                      ),
                    ),
                  ),
                  const Spacer(),
                  // "Choose" Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: SizedBox(
                      width: 200,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF6354D9),
                          elevation: 10,
                          shadowColor: Colors.black.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: Text(
                          'Start',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
