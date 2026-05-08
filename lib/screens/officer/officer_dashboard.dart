import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../main.dart';
import '../admin/events_screen.dart';
import '../admin/duties_screen.dart';
import '../admin/analytics_screen.dart';

class OfficerDashboard extends StatefulWidget {
  const OfficerDashboard({super.key});

  @override
  State<OfficerDashboard> createState() => _OfficerDashboardState();
}

class _OfficerDashboardState extends State<OfficerDashboard> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    _OfficerHome(onNavigate: (i) => setState(() => _currentIndex = i)),
    const EventsScreen(),
    const DutiesScreen(),
    const AnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: HudyatColors.surface,
          border: Border(top: BorderSide(color: HudyatColors.divider)),
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Events'),
              BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded), label: 'Duties'),
              BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Analytics'),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfficerHome extends StatelessWidget {
  final void Function(int) onNavigate;
  const _OfficerHome({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.profile?['full_name'] ?? 'Officer';

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              backgroundColor: HudyatColors.background,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: Text(
                  'Hello, ${name.split(' ').first} 👋',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: HudyatColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                background: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [HudyatColors.accent.withOpacity(0.6), HudyatColors.background],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 48,
                      left: 20,
                      child: Image.asset('assets/images/hudyat_logo.png', height: 52),
                    ),
                  ],
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16, top: 8),
                  child: GestureDetector(
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: HudyatColors.card,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Text('Log Out', style: TextStyle(color: HudyatColors.textPrimary, fontWeight: FontWeight.w700)),
                          content: const Text('Are you sure you want to log out?', style: TextStyle(color: HudyatColors.textSecondary)),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: HudyatColors.textSecondary))),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Log Out', style: TextStyle(color: HudyatColors.accent, fontWeight: FontWeight.w700))),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        await context.read<AuthProvider>().logout();
                        if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: HudyatColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: HudyatColors.divider),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: HudyatColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.blueAccent.withOpacity(0.4)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded,
                              size: 12, color: Colors.blueAccent),
                          SizedBox(width: 6),
                          Text(
                            'OFFICER',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        color: HudyatColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _OfficerActionCard(
                      icon: Icons.calendar_month_rounded,
                      label: 'Manage Events',
                      subtitle: 'Create and track organization events',
                      color: HudyatColors.success,
                      onTap: () => onNavigate(1),
                    ),
                    const SizedBox(height: 10),
                    _OfficerActionCard(
                      icon: Icons.assignment_rounded,
                      label: 'Log Duties',
                      subtitle: 'Record member duties per event',
                      color: HudyatColors.accent,
                      onTap: () => onNavigate(2),
                    ),
                    const SizedBox(height: 10),
                    _OfficerActionCard(
                      icon: Icons.bar_chart_rounded,
                      label: 'View Analytics',
                      subtitle: 'Member performance and leaderboard',
                      color: HudyatColors.gold,
                      onTap: () => onNavigate(3),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfficerActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _OfficerActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: HudyatColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: HudyatColors.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: HudyatColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: HudyatColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: HudyatColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
