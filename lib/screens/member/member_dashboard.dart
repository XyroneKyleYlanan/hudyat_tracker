import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/duty_service.dart';
import '../../main.dart';

class MemberDashboard extends StatefulWidget {
  const MemberDashboard({super.key});

  @override
  State<MemberDashboard> createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _MemberHome(),
    _MyDuties(),
    _MyPerformance(),
  ];

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
              BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded), label: 'My Duties'),
              BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Performance'),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberHome extends StatefulWidget {
  const _MemberHome();

  @override
  State<_MemberHome> createState() => _MemberHomeState();
}

class _MemberHomeState extends State<_MemberHome> {
  final _service = DutyService();
  Map<String, dynamic>? _perf;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    final memberId = auth.profile?['id']?.toString();
    if (memberId == null) return;
    final perf = await _service.getMemberPerformance(memberId);
    if (mounted) setState(() => _perf = perf);
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

  void _showChangePasswordSheet(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    String? errorMsg;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: HudyatColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 12,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: HudyatColors.divider, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                const Text('Change Password', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: HudyatColors.textPrimary, letterSpacing: -0.3)),
                const SizedBox(height: 20),
                TextField(
                  controller: currentCtrl,
                  obscureText: obscureCurrent,
                  style: const TextStyle(color: HudyatColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    suffixIcon: IconButton(
                      icon: Icon(obscureCurrent ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: HudyatColors.textSecondary, size: 18),
                      onPressed: () => setSheetState(() => obscureCurrent = !obscureCurrent),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newCtrl,
                  obscureText: obscureNew,
                  style: const TextStyle(color: HudyatColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    suffixIcon: IconButton(
                      icon: Icon(obscureNew ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: HudyatColors.textSecondary, size: 18),
                      onPressed: () => setSheetState(() => obscureNew = !obscureNew),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmCtrl,
                  obscureText: obscureConfirm,
                  style: const TextStyle(color: HudyatColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: HudyatColors.textSecondary, size: 18),
                      onPressed: () => setSheetState(() => obscureConfirm = !obscureConfirm),
                    ),
                  ),
                ),
                if (errorMsg != null) ...[
                  const SizedBox(height: 10),
                  Text(errorMsg!, style: const TextStyle(color: HudyatColors.accent, fontSize: 13)),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (currentCtrl.text.isEmpty || newCtrl.text.isEmpty || confirmCtrl.text.isEmpty) {
                        setSheetState(() => errorMsg = 'All fields are required');
                        return;
                      }
                      if (newCtrl.text != confirmCtrl.text) {
                        setSheetState(() => errorMsg = 'New passwords do not match');
                        return;
                      }
                      if (newCtrl.text.length < 6) {
                        setSheetState(() => errorMsg = 'New password must be at least 6 characters');
                        return;
                      }
                      final result = await _service.changePassword(
                        currentPassword: currentCtrl.text,
                        newPassword: newCtrl.text,
                      );
                      if (result['message'] != null && ctx.mounted) {
                        Navigator.pop(ctx);
                      } else {
                        setSheetState(() => errorMsg = result['error'] ?? 'Failed to change password');
                      }
                    },
                    child: const Text('Change Password'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.profile?['full_name'] ?? 'Member';
    final totalDuties = _perf == null ? '—' : '${_perf!['total_duties'] ?? 0}';
    final eventCoverage = _perf == null ? '—' : '${_perf!['events_attended'] ?? 0}/${_perf!['total_events'] ?? 0}';

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
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: HudyatColors.textPrimary, letterSpacing: -0.5),
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
                  padding: const EdgeInsets.only(top: 8),
                  child: GestureDetector(
                    onTap: () => _showChangePasswordSheet(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: HudyatColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: HudyatColors.divider),
                      ),
                      child: const Icon(Icons.key_rounded, color: HudyatColors.textSecondary, size: 20),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16, top: 8, left: 8),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: HudyatColors.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: HudyatColors.success.withOpacity(0.4)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_rounded, size: 12, color: HudyatColors.success),
                          SizedBox(width: 6),
                          Text('MEMBER', style: TextStyle(color: HudyatColors.success, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text('Overview', style: TextStyle(color: HudyatColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: HudyatColors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: HudyatColors.divider),
                      ),
                      child: Row(
                        children: [
                          _StatBox(label: 'Total Duties', value: totalDuties, icon: Icons.assignment_rounded, color: HudyatColors.accent),
                          const SizedBox(width: 12),
                          _StatBox(label: 'Event Coverage', value: eventCoverage, icon: Icons.event_available_rounded, color: HudyatColors.success),
                        ],
                      ),
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

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _MyDuties extends StatefulWidget {
  const _MyDuties();

  @override
  State<_MyDuties> createState() => _MyDutiesState();
}

class _MyDutiesState extends State<_MyDuties> {
  final _dutyService = DutyService();
  List<Map<String, dynamic>> _duties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDuties();
  }

  Future<void> _loadDuties() async {
    final auth = context.read<AuthProvider>();
    final memberId = auth.profile?['id']?.toString();
    if (memberId == null) {
      setState(() => _isLoading = false);
      return;
    }
    final duties = await _dutyService.getDutiesByMember(memberId);
    setState(() {
      _duties = duties;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                'My Duties',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: HudyatColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: HudyatColors.accent))
                  : _duties.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.assignment_outlined, size: 56, color: HudyatColors.textSecondary),
                              SizedBox(height: 12),
                              Text(
                                'No duties yet',
                                style: TextStyle(color: HudyatColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _duties.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final duty = _duties[index];
                            final eventDate = duty['event_date'] as String?;
                            final date = eventDate != null
                                ? DateFormat('MMM dd, yyyy').format(DateTime.parse(eventDate))
                                : '';
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: HudyatColors.card,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: HudyatColors.divider),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: HudyatColors.accent.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.assignment_rounded, color: HudyatColors.accent, size: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          duty['event_name'] ?? 'Unknown Event',
                                          style: const TextStyle(
                                            color: HudyatColors.textPrimary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: HudyatColors.accent.withOpacity(0.12),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                duty['role_assigned'] ?? '',
                                                style: const TextStyle(
                                                  color: HudyatColors.accent,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(date, style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 12)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyPerformance extends StatefulWidget {
  const _MyPerformance();

  @override
  State<_MyPerformance> createState() => _MyPerformanceState();
}

class _MyPerformanceState extends State<_MyPerformance> {
  final _dutyService = DutyService();
  Map<String, dynamic>? _performance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPerformance();
  }

  Future<void> _loadPerformance() async {
    final auth = context.read<AuthProvider>();
    final memberId = auth.profile?['id']?.toString();
    if (memberId == null) {
      setState(() => _isLoading = false);
      return;
    }
    final perf = await _dutyService.getMemberPerformance(memberId);
    setState(() {
      _performance = perf;
      _isLoading = false;
    });
  }

  Color _classificationColor(String? classification) {
    switch (classification) {
      case 'Highly Active':
        return HudyatColors.success;
      case 'Moderately Active':
        return HudyatColors.warning;
      case 'Low Participation':
        return HudyatColors.accent;
      default:
        return HudyatColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: HudyatColors.accent))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Performance',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: HudyatColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_performance != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: HudyatColors.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: HudyatColors.divider),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: _classificationColor(_performance!['classification']).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _classificationColor(_performance!['classification']).withOpacity(0.4),
                                ),
                              ),
                              child: Text(
                                _performance!['classification'] ?? 'No Data Yet',
                                style: TextStyle(
                                  color: _classificationColor(_performance!['classification']),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                _PerfStat(
                                  label: 'Total Duties',
                                  value: '${_performance!['total_duties'] ?? 0}',
                                  color: HudyatColors.accent,
                                ),
                                const SizedBox(width: 12),
                                _PerfStat(
                                  label: 'Event Coverage',
                                  value: '${_performance!['events_attended'] ?? 0}/${_performance!['total_events'] ?? 0}',
                                  color: HudyatColors.success,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ] else
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Text(
                            'No performance data yet.',
                            style: TextStyle(color: HudyatColors.textSecondary, fontSize: 15),
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: HudyatColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: HudyatColors.divider),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Classification Guide',
                            style: TextStyle(color: HudyatColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                          const SizedBox(height: 14),
                          const _ClassificationGuideRow(label: 'Highly Active', description: '10 or more duties', color: HudyatColors.success),
                          const SizedBox(height: 10),
                          const _ClassificationGuideRow(label: 'Moderately Active', description: '5 to 9 duties', color: HudyatColors.warning),
                          const SizedBox(height: 10),
                          const _ClassificationGuideRow(label: 'Low Participation', description: '1 to 4 duties', color: HudyatColors.accent),
                          const SizedBox(height: 10),
                          const _ClassificationGuideRow(label: 'No Data Yet', description: 'No duties logged yet', color: HudyatColors.textSecondary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _PerfStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _PerfStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 30, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _ClassificationGuideRow extends StatelessWidget {
  final String label;
  final String description;
  final Color color;

  const _ClassificationGuideRow({required this.label, required this.description, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
        const Spacer(),
        Text(description, style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 13)),
      ],
    );
  }
}
