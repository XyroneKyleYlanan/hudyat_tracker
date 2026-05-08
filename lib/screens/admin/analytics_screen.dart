import 'package:flutter/material.dart';
import '../../services/duty_service.dart';
import '../../main.dart';
import 'reports_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _service = DutyService();
  List<Map<String, dynamic>> _performance = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await _service.getAllPerformance();
      if (mounted) setState(() { _performance = data; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Could not connect to server.\nCheck your connection and try again.'; _isLoading = false; });
    }
  }

  int _duties(Map<String, dynamic> m) =>
      int.tryParse(m['total_duties'].toString()) ?? 0;

  int get _totalMembers => _performance.length;
  int get _totalDuties => _performance.fold(0, (s, m) => s + _duties(m));
  double get _avgDuties => _totalMembers == 0 ? 0 : _totalDuties / _totalMembers;

  int get _highlyActive =>
      _performance.where((m) => m['classification'] == 'Highly Active').length;
  int get _moderatelyActive =>
      _performance.where((m) => m['classification'] == 'Moderately Active').length;
  int get _lowParticipation =>
      _performance.where((m) => m['classification'] == 'Low Participation').length;

  Color _classColor(String? c) {
    switch (c) {
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

  int get _noDataYet =>
      _performance.where((m) => m['classification'] == 'No Data Yet').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: HudyatColors.accent))
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi_off_rounded, size: 52, color: HudyatColors.textSecondary),
                          const SizedBox(height: 16),
                          Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 14, height: 1.5)),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _load,
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
            : RefreshIndicator(
                color: HudyatColors.accent,
                backgroundColor: HudyatColors.card,
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Analytics',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: HudyatColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Participation overview',
                          style: TextStyle(color: HudyatColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Overall stats ──────────────────────────────────────
                    Row(
                      children: [
                        _StatCard(
                          label: 'Members',
                          value: '$_totalMembers',
                          icon: Icons.people_rounded,
                          color: Colors.blueAccent,
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          label: 'Total Duties',
                          value: '$_totalDuties',
                          icon: Icons.assignment_rounded,
                          color: HudyatColors.accent,
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          label: 'Duties / Member',
                          value: _avgDuties.toStringAsFixed(1),
                          icon: Icons.analytics_rounded,
                          color: HudyatColors.gold,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Classification breakdown ────────────────────────────
                    _sectionLabel('Classification Breakdown'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: HudyatColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: HudyatColors.divider),
                      ),
                      child: Column(
                        children: [
                          _ClassRow(
                            label: 'Highly Active',
                            count: _highlyActive,
                            total: _totalMembers,
                            color: HudyatColors.success,
                          ),
                          const SizedBox(height: 14),
                          _ClassRow(
                            label: 'Moderately Active',
                            count: _moderatelyActive,
                            total: _totalMembers,
                            color: HudyatColors.warning,
                          ),
                          const SizedBox(height: 14),
                          _ClassRow(
                            label: 'Low Participation',
                            count: _lowParticipation,
                            total: _totalMembers,
                            color: HudyatColors.accent,
                          ),
                          const SizedBox(height: 14),
                          _ClassRow(
                            label: 'No Data Yet',
                            count: _noDataYet,
                            total: _totalMembers,
                            color: HudyatColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Top 5 ─────────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(child: _sectionLabel('Top Performers')),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ReportsScreen()),
                          ),
                          child: const Text(
                            'See All →',
                            style: TextStyle(
                              color: HudyatColors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ..._performance.take(5).toList().asMap().entries.map((entry) {
                      final rank = entry.key + 1;
                      final m = entry.value;
                      final cls = m['classification'] as String?;
                      final color = _classColor(cls);
                      final name = m['full_name'] as String? ?? 'Unknown';
                      final dutyCount = _duties(m);
                      final topCount = _performance.isNotEmpty ? _duties(_performance.first) : 1;
                      final barWidth = topCount == 0 ? 0.0 : dutyCount / topCount;
                      final rankColor = rank == 1
                          ? HudyatColors.gold
                          : rank == 2
                              ? const Color(0xFFAAAAAA)
                              : rank == 3
                                  ? const Color(0xFFCD7F32)
                                  : HudyatColors.textSecondary;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                          decoration: BoxDecoration(
                            color: HudyatColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: rank <= 3 ? rankColor.withOpacity(0.3) : HudyatColors.divider,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 30,
                                    child: Text(
                                      '#$rank',
                                      style: TextStyle(
                                        color: rankColor,
                                        fontWeight: FontWeight.w800,
                                        fontSize: rank <= 3 ? 15 : 13,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            color: HudyatColors.textPrimary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          m['student_id'] ?? 'No ID',
                                          style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$dutyCount',
                                    style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text('duties', style: TextStyle(color: HudyatColors.textSecondary, fontSize: 10)),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      cls == 'Highly Active' ? 'High'
                                          : cls == 'Moderately Active' ? 'Mid'
                                          : cls == 'Low Participation' ? 'Low'
                                          : 'None',
                                      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: barWidth,
                                  minHeight: 5,
                                  backgroundColor: HudyatColors.cardElevated,
                                  valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.7)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReportsScreen()),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: HudyatColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: HudyatColors.divider),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_rounded, color: HudyatColors.textSecondary, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'View All Members in Reports',
                              style: TextStyle(
                                color: HudyatColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward_rounded, color: HudyatColors.textSecondary, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          color: HudyatColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      );
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: HudyatColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _ClassRow extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _ClassRow({required this.label, required this.count, required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : count / total;
    return Column(
      children: [
        Row(
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label, style: const TextStyle(color: HudyatColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
            Text(
              '$count member${count != 1 ? 's' : ''}',
              style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: HudyatColors.cardElevated,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

