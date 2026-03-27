//navbar
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_screen.dart';
import 'demandes_screen.dart';
import 'experiences_screen.dart';
import 'chatbot_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    _PlaceholderScreen(label: 'RDV'),
    ChatbotScreen(),
    _PlaceholderScreen(label: 'Carte Santé'),
    _PlaceholderScreen(label: 'Dossier'),
    _PlaceholderScreen(label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _HealioNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

// ─── Placeholder for unimplemented screens ────────────────────────────────────
class _PlaceholderScreen extends StatelessWidget {
  final String label;
  const _PlaceholderScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FBF8),
      body: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1FAF87),
          ),
        ),
      ),
    );
  }
}

// ─── Bottom Navigation Bar ────────────────────────────────────────────────────
class _HealioNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _HealioNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      // ── outer margin gives floating effect ──
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1FAF87), // ← green background
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1FAF87).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              index: 0,
              currentIndex: currentIndex,
              svgAsset: 'assets/icons/home.svg',
              label: 'Accueil',
              onTap: onTap,
            ),
            _NavItem(
              index: 1,
              currentIndex: currentIndex,
              svgAsset: 'assets/icons/calendar.svg',
              label: 'RDV',
              onTap: onTap,
            ),
            _NavItem(
              index: 2,
              currentIndex: currentIndex,
              svgAsset: 'assets/icons/chat.svg',
              label: 'Chat',
              onTap: onTap,
            ),
            _NavItem(
              index: 3,
              currentIndex: currentIndex,
              svgAsset: 'assets/icons/card.svg',
              label: 'Carte',
              onTap: onTap,
            ),
            _NavItem(
              index: 4,
              currentIndex: currentIndex,
              svgAsset: 'assets/icons/dossier.svg',
              label: 'Dossier',
              onTap: onTap,
            ),
            _NavItem(
              index: 5,
              currentIndex: currentIndex,
              svgAsset: 'assets/icons/profile.svg',
              label: 'Profil',
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Nav Item ─────────────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final String svgAsset;
  final String label;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.svgAsset,
    required this.label,
    required this.onTap,
  });

  bool get isSelected => index == currentIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.transparent, // ← white pill when active
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              svgAsset,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                isSelected
                    ? const Color(0xFF1FAF87) // ← green icon when active
                    : Colors.white, // ← white icon when inactive
                BlendMode.srcIn,
              ),
            ),
            // ── show label only for active tab ──
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1FAF87), // ← green text when active
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── BACKEND TODO ─────────────────────────────────────────────────────────────
// - Replace _PlaceholderScreen for RDV     → real RDV screen with API data
// - Replace _PlaceholderScreen for Chat    → real AI chatbot screen
// - Replace _PlaceholderScreen for Carte   → real health card screen
// - Replace _PlaceholderScreen for Dossier → real medical dossier screen
// - Replace _PlaceholderScreen for Profil  → real profile screen with user data from API
