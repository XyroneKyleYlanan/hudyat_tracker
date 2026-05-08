import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/duty_service.dart';
import '../../main.dart';
import 'events_screen.dart';
import 'duties_screen.dart';
import 'members_screen.dart';
import 'analytics_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    _AdminHome(onNavigate: (i) => setState(() => _currentIndex = i)),
    const MembersScreen(),
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
              BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: 'Members'),
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

class _AdminHome extends StatefulWidget {
  final void Function(int) onNavigate;
  const _AdminHome({required this.onNavigate});

  @override
  State<_AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<_AdminHome> {
  final _service = DutyService();
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _service.getDashboardStats();
      if (mounted) setState(() => _stats = stats);
    } catch (_) {}
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: HudyatColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out', style: TextStyle(color: HudyatColors.textPrimary, fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to log out?', style: TextStyle(color: HudyatColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: HudyatColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out', style: TextStyle(color: HudyatColors.accent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.profile?['full_name'] ?? 'Admin';

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
                    onTap: _confirmLogout,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: HudyatColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: HudyatColors.divider),
                      ),
                      child: const Icon(Icons.logout_rounded, color: HudyatColors.textSecondary, size: 20),
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
                    // Role badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: HudyatColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: HudyatColors.accent.withOpacity(0.5)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_rounded, size: 11, color: HudyatColors.accent),
                          SizedBox(width: 5),
                          Text('ADMINISTRATOR', style: TextStyle(color: HudyatColors.accent, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Live stats row
                    const Text('Overview', style: TextStyle(color: HudyatColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _StatCard(
                          label: 'Members',
                          value: _stats == null ? '—' : '${_stats!['total_members']}',
                          icon: Icons.people_rounded,
                          color: Colors.blueAccent,
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          label: 'Events',
                          value: _stats == null ? '—' : '${_stats!['total_events']}',
                          icon: Icons.calendar_month_rounded,
                          color: HudyatColors.success,
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          label: 'Duties',
                          value: _stats == null ? '—' : '${_stats!['total_duties']}',
                          icon: Icons.assignment_rounded,
                          color: HudyatColors.accent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Quick actions
                    const Text('Quick Actions', style: TextStyle(color: HudyatColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
                    const SizedBox(height: 12),
                    _ActionCard(icon: Icons.people_rounded, label: 'Manage Members', subtitle: 'Add, view, and manage all members', color: Colors.blueAccent, onTap: () => widget.onNavigate(1)),
                    const SizedBox(height: 10),
                    _ActionCard(icon: Icons.calendar_month_rounded, label: 'Manage Events', subtitle: 'Create and track organization events', color: HudyatColors.success, onTap: () => widget.onNavigate(2)),
                    const SizedBox(height: 10),
                    _ActionCard(icon: Icons.assignment_rounded, label: 'Log Duties', subtitle: 'Record member duties per event', color: HudyatColors.accent, onTap: () => widget.onNavigate(3)),
                    const SizedBox(height: 10),
                    _ActionCard(icon: Icons.bar_chart_rounded, label: 'View Reports', subtitle: 'Analytics and performance summaries', color: HudyatColors.gold, onTap: () => widget.onNavigate(4)),
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: HudyatColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: HudyatColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.label, required this.subtitle, required this.color, required this.onTap});

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
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: HudyatColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: HudyatColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
