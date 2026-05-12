import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/duty_provider.dart';
import '../../providers/event_provider.dart';
import '../../main.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<EventProvider>().loadEvents();
      context.read<DutyProvider>().loadAllDuties();
      context.read<DutyProvider>().loadMembers();
    });
  }

  Map<DateTime, List<Map<String, dynamic>>> _buildEventMap(List<Map<String, dynamic>> events) {
    final map = <DateTime, List<Map<String, dynamic>>>{};
    for (final e in events) {
      final raw = DateTime.parse(e['event_date']);
      final day = DateTime.utc(raw.year, raw.month, raw.day);
      map[day] = [...(map[day] ?? []), e];
    }
    return map;
  }

  List<Map<String, dynamic>> _getEventsForDay(
    DateTime day,
    Map<DateTime, List<Map<String, dynamic>>> eventMap,
  ) {
    return eventMap[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  Color _avatarColor(String name) {
    const colors = [
      Color(0xFF5C6BC0), Color(0xFF26A69A), Color(0xFFEF6C00),
      Color(0xFF7B1FA2), Color(0xFF2E7D32), Color(0xFF00838F),
      Color(0xFFC62828), Color(0xFF4527A0),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  // ── Time helper methods ──────────────────────────────────────────────────────

  String _formatTimeDisplay(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final min = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$min $period';
  }

  String _formatTimeApi(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  // ── Event participants bottom sheet ──────────────────────────────────────────

  void _showEventParticipants(Map<String, dynamic> event) {
    final eventId = event['id'].toString();
    final eventName = event['name'] as String? ?? '';
    final date = DateTime.parse(event['event_date']);
    final description = event['description'] as String? ?? '';

    // Parse optional event time for display in the header
    TimeOfDay? eventTime;
    final rawTime = event['event_time'] as String?;
    if (rawTime != null && rawTime.isNotEmpty) {
      final parts = rawTime.split(':');
      if (parts.length >= 2) {
        eventTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ChangeNotifierProvider.value(
        value: context.read<DutyProvider>(),
        child: Consumer<DutyProvider>(
          builder: (ctx, provider, _) {
            final duties = provider.duties
                .where((d) => d['event_id']?.toString() == eventId)
                .toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.82,
              decoration: const BoxDecoration(
                color: HudyatColors.card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(color: HudyatColors.divider, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            color: HudyatColors.accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(DateFormat('d').format(date), style: const TextStyle(color: HudyatColors.accent, fontSize: 20, fontWeight: FontWeight.w800)),
                              Text(DateFormat('MMM').format(date).toUpperCase(), style: const TextStyle(color: HudyatColors.accent, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(eventName, style: const TextStyle(color: HudyatColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 17), maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 3),
                              Text(DateFormat('EEEE, MMMM dd, yyyy').format(date), style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 12)),
                              if (eventTime != null) ...[
                                const SizedBox(height: 2),
                                Text(_formatTimeDisplay(eventTime), style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 12)),
                              ],
                              if (description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(description, style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 12, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Edit event button
                        GestureDetector(
                          onTap: () => _showEditEventSheet(event),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: HudyatColors.cardElevated, borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.edit_rounded, color: HudyatColors.textSecondary, size: 18),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Add participant button
                        GestureDetector(
                          onTap: () => _showAddParticipantSheet(ctx, provider, eventId),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: HudyatColors.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.person_add_rounded, color: HudyatColors.accent, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 10),
                    child: Text(
                      'PARTICIPANTS  •  ${duties.length}',
                      style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1),
                    ),
                  ),
                  Expanded(
                    child: duties.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline_rounded, size: 44, color: HudyatColors.textSecondary),
                                SizedBox(height: 12),
                                Text('No participants yet', style: TextStyle(color: HudyatColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
                                SizedBox(height: 4),
                                Text('Tap + to add a participant', style: TextStyle(color: HudyatColors.textSecondary, fontSize: 12)),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                            itemCount: duties.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (_, i) {
                              final d = duties[i];
                              final name = (d['member_name'] ?? d['full_name']) as String? ?? 'Unknown';
                              final role = d['role_assigned'] as String? ?? '';
                              final notes = d['notes'] as String? ?? '';
                              final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
                              final avatarColor = _avatarColor(name);

                              return Container(
                                padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
                                decoration: BoxDecoration(
                                  color: HudyatColors.cardElevated,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38, height: 38,
                                      decoration: BoxDecoration(
                                        color: avatarColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(initials, style: TextStyle(color: avatarColor, fontWeight: FontWeight.w700, fontSize: 13)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(name, style: const TextStyle(color: HudyatColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                                          const SizedBox(height: 3),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: HudyatColors.accent.withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(role, style: const TextStyle(color: HudyatColors.accent, fontSize: 11, fontWeight: FontWeight.w600)),
                                              ),
                                              if (notes.isNotEmpty) ...[
                                                const SizedBox(width: 6),
                                                Expanded(child: Text(notes, style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_rounded, size: 16, color: HudyatColors.textSecondary),
                                      onPressed: () => _showEditDutySheet(ctx, provider, d),
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(8),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, size: 16, color: HudyatColors.accent),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            backgroundColor: HudyatColors.card,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                            title: const Text('Remove Participant', style: TextStyle(color: HudyatColors.textPrimary, fontWeight: FontWeight.w700)),
                                            content: Text('Remove $name from this event?', style: const TextStyle(color: HudyatColors.textSecondary)),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: HudyatColors.textSecondary))),
                                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove', style: TextStyle(color: HudyatColors.accent, fontWeight: FontWeight.w700))),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) provider.deleteDuty(d['id'].toString());
                                      },
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(8),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showAddParticipantSheet(BuildContext sheetCtx, DutyProvider provider, String eventId) {
    String? selectedMemberId;
    String? selectedMemberName;
    final roleController = TextEditingController();
    final notesController = TextEditingController();
    String? errorMsg;

    showModalBottomSheet(
      context: sheetCtx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          void pickMember() {
            final searchCtrl = TextEditingController();
            showDialog(
              context: ctx,
              builder: (_) => StatefulBuilder(
                builder: (dlgCtx, setDlg) {
                  final q = searchCtrl.text.toLowerCase();
                  final visible = provider.members.where((m) {
                    final n = (m['full_name'] as String? ?? '').toLowerCase();
                    return q.isEmpty || n.contains(q);
                  }).toList();
                  return AlertDialog(
                    backgroundColor: HudyatColors.card,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text('Select Member', style: TextStyle(color: HudyatColors.textPrimary, fontWeight: FontWeight.w700)),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: searchCtrl,
                            onChanged: (_) => setDlg(() {}),
                            decoration: const InputDecoration(
                              hintText: 'Search members…',
                              prefixIcon: Icon(Icons.search_rounded, size: 18),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Flexible(
                            child: ListView(
                              shrinkWrap: true,
                              children: visible.map((m) => ListTile(
                                title: Text(m['full_name'] ?? '', style: const TextStyle(color: HudyatColors.textPrimary, fontSize: 14)),
                                subtitle: Text(m['student_id'] ?? '', style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 12)),
                                onTap: () {
                                  setSheetState(() {
                                    selectedMemberId = m['id'].toString();
                                    selectedMemberName = m['full_name'] as String? ?? '';
                                  });
                                  Navigator.pop(dlgCtx);
                                },
                              )).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return Container(
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
                  const Text('Add Participant', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: HudyatColors.textPrimary, letterSpacing: -0.3)),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: pickMember,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(color: HudyatColors.cardElevated, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedMemberName ?? 'Select Member',
                              style: TextStyle(color: selectedMemberName != null ? HudyatColors.textPrimary : HudyatColors.textSecondary),
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded, color: HudyatColors.textSecondary, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: roleController,
                    style: const TextStyle(color: HudyatColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Role Assigned',
                      hintText: 'e.g. Photographer, Videographer, etc.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesController,
                    style: const TextStyle(color: HudyatColors.textPrimary),
                    decoration: const InputDecoration(labelText: 'Notes (optional)'),
                    maxLines: 2,
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
                        if (selectedMemberId == null || roleController.text.isEmpty) {
                          setSheetState(() => errorMsg = 'Please select a member and enter a role');
                          return;
                        }
                        final success = await provider.logDuty(
                          memberId: selectedMemberId!,
                          eventId: eventId,
                          roleAssigned: roleController.text.trim(),
                          notes: notesController.text.trim(),
                        );
                        if (success && ctx.mounted) Navigator.pop(ctx);
                      },
                      child: const Text('Add Participant'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditDutySheet(BuildContext sheetCtx, DutyProvider provider, Map<String, dynamic> duty) {
    final roleController = TextEditingController(text: duty['role_assigned'] ?? '');
    final notesController = TextEditingController(text: duty['notes'] ?? '');

    showModalBottomSheet(
      context: sheetCtx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, _) => Container(
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
                const Text('Edit Duty', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: HudyatColors.textPrimary, letterSpacing: -0.3)),
                const SizedBox(height: 6),
                Text(duty['full_name'] ?? '', style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 20),
                TextField(
                  controller: roleController,
                  style: const TextStyle(color: HudyatColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Role Assigned'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  style: const TextStyle(color: HudyatColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Notes (optional)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (roleController.text.isEmpty) return;
                      final success = await provider.updateDuty(
                        dutyId: duty['id'].toString(),
                        roleAssigned: roleController.text.trim(),
                        notes: notesController.text.trim(),
                      );
                      if (success && ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateEventSheet() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    DateTime? selectedDate = _selectedDay;
    TimeOfDay? selectedTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: HudyatColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: HudyatColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Create Event',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: HudyatColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                style: const TextStyle(color: HudyatColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Event Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                style: const TextStyle(color: HudyatColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Description (optional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              // Date picker row
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    builder: (context, child) => Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: HudyatColors.accent,
                          surface: HudyatColors.card,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) setSheetState(() => selectedDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: HudyatColors.cardElevated,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: HudyatColors.textSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        selectedDate == null
                            ? 'Select Event Date'
                            : DateFormat('MMMM dd, yyyy').format(selectedDate!),
                        style: TextStyle(
                          color: selectedDate == null
                              ? HudyatColors.textSecondary
                              : HudyatColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Time picker row
              GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime ?? TimeOfDay.now(),
                    builder: (context, child) => Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: HudyatColors.accent,
                          surface: HudyatColors.card,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) setSheetState(() => selectedTime = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(color: HudyatColors.cardElevated, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded, color: HudyatColors.textSecondary, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectedTime == null ? 'Set Time (optional)' : _formatTimeDisplay(selectedTime!),
                          style: TextStyle(
                            color: selectedTime == null ? HudyatColors.textSecondary : HudyatColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (selectedTime != null)
                        GestureDetector(
                          onTap: () => setSheetState(() => selectedTime = null),
                          child: const Icon(Icons.close_rounded, color: HudyatColors.textSecondary, size: 16),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty || selectedDate == null) return;
                    final success = await context.read<EventProvider>().createEvent(
                          name: nameController.text.trim(),
                          description: descController.text.trim(),
                          eventDate: selectedDate!,
                          eventTime: selectedTime != null ? _formatTimeApi(selectedTime!) : null,
                        );
                    if (success && context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Create Event'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditEventSheet(Map<String, dynamic> event) {
    final nameController = TextEditingController(text: event['name'] as String? ?? '');
    final descController = TextEditingController(text: event['description'] as String? ?? '');
    DateTime? selectedDate = DateTime.parse(event['event_date']);

    // Pre-fill time if present ("HH:MM" or "HH:MM:SS")
    TimeOfDay? selectedTime;
    final rawTime = event['event_time'] as String?;
    if (rawTime != null && rawTime.isNotEmpty) {
      final parts = rawTime.split(':');
      if (parts.length >= 2) {
        selectedTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: HudyatColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: HudyatColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Edit Event',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: HudyatColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                style: const TextStyle(color: HudyatColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Event Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                style: const TextStyle(color: HudyatColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Description (optional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              // Date picker row
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    builder: (context, child) => Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: HudyatColors.accent,
                          surface: HudyatColors.card,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) setSheetState(() => selectedDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: HudyatColors.cardElevated,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: HudyatColors.textSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        selectedDate == null
                            ? 'Select Event Date'
                            : DateFormat('MMMM dd, yyyy').format(selectedDate!),
                        style: TextStyle(
                          color: selectedDate == null
                              ? HudyatColors.textSecondary
                              : HudyatColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Time picker row
              GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime ?? TimeOfDay.now(),
                    builder: (context, child) => Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: HudyatColors.accent,
                          surface: HudyatColors.card,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) setSheetState(() => selectedTime = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(color: HudyatColors.cardElevated, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded, color: HudyatColors.textSecondary, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectedTime == null ? 'Set Time (optional)' : _formatTimeDisplay(selectedTime!),
                          style: TextStyle(
                            color: selectedTime == null ? HudyatColors.textSecondary : HudyatColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (selectedTime != null)
                        GestureDetector(
                          onTap: () => setSheetState(() => selectedTime = null),
                          child: const Icon(Icons.close_rounded, color: HudyatColors.textSecondary, size: 16),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty || selectedDate == null) return;
                    final success = await context.read<EventProvider>().updateEvent(
                          id: event['id'].toString(),
                          name: nameController.text.trim(),
                          description: descController.text.trim(),
                          eventDate: selectedDate!,
                          eventTime: selectedTime != null ? _formatTimeApi(selectedTime!) : null,
                        );
                    if (success && context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventProvider>();
    final eventMap = _buildEventMap(provider.events);

    final filteredEvents = _selectedDay != null
        ? _getEventsForDay(_selectedDay!, eventMap)
        : provider.events;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Events',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: HudyatColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: _showCreateEventSheet,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: HudyatColors.accent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: HudyatColors.accent.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),

            // Calendar
            Container(
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              decoration: BoxDecoration(
                color: HudyatColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: HudyatColors.divider),
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: (day) => _getEventsForDay(day, eventMap),
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {CalendarFormat.month: 'Month'},
                startingDayOfWeek: StartingDayOfWeek.sunday,
                rowHeight: 36,
                daysOfWeekHeight: 20,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = isSameDay(_selectedDay, selectedDay) ? null : selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) => setState(() => _focusedDay = focusedDay),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  defaultTextStyle: const TextStyle(color: HudyatColors.textPrimary, fontSize: 13),
                  weekendTextStyle: const TextStyle(color: HudyatColors.textSecondary, fontSize: 13),
                  selectedDecoration: const BoxDecoration(
                    color: HudyatColors.accent,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: HudyatColors.accent.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: const TextStyle(color: HudyatColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13),
                  selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                  markerDecoration: const BoxDecoration(
                    color: HudyatColors.gold,
                    shape: BoxShape.circle,
                  ),
                  markerSize: 5,
                  markersMaxCount: 3,
                  outsideTextStyle: const TextStyle(color: HudyatColors.divider, fontSize: 13),
                ),
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                  titleTextStyle: const TextStyle(
                    color: HudyatColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  leftChevronIcon: const Icon(Icons.chevron_left_rounded, color: HudyatColors.textSecondary),
                  rightChevronIcon: const Icon(Icons.chevron_right_rounded, color: HudyatColors.textSecondary),
                  headerPadding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: HudyatColors.divider)),
                  ),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: HudyatColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                  weekendStyle: TextStyle(color: HudyatColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            // Section label
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(
                    _selectedDay != null
                        ? DateFormat('MMMM d').format(_selectedDay!)
                        : 'All Events',
                    style: const TextStyle(
                      color: HudyatColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  if (_selectedDay != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _selectedDay = null),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: HudyatColors.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Clear',
                          style: TextStyle(color: HudyatColors.accent, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    '${filteredEvents.length} event${filteredEvents.length == 1 ? '' : 's'}',
                    style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Event list
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: HudyatColors.accent))
                  : filteredEvents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.event_busy_rounded, size: 48, color: HudyatColors.textSecondary),
                              const SizedBox(height: 12),
                              Text(
                                _selectedDay != null ? 'No events on this day' : 'No events yet',
                                style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 15, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedDay != null ? 'Tap + to create one' : 'Tap + to create the first event',
                                style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          itemCount: filteredEvents.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final event = filteredEvents[index];
                            final date = DateTime.parse(event['event_date']);

                            // Parse optional time for list card display
                            TimeOfDay? cardTime;
                            final cardRawTime = event['event_time'] as String?;
                            if (cardRawTime != null && cardRawTime.isNotEmpty) {
                              final parts = cardRawTime.split(':');
                              if (parts.length >= 2) {
                                cardTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
                              }
                            }

                            return GestureDetector(
                              onTap: () => _showEventParticipants(event),
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
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: HudyatColors.accent.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          DateFormat('d').format(date),
                                          style: const TextStyle(
                                            color: HudyatColors.accent,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        Text(
                                          DateFormat('MMM').format(date).toUpperCase(),
                                          style: const TextStyle(
                                            color: HudyatColors.accent,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event['name'],
                                          style: const TextStyle(
                                            color: HudyatColors.textPrimary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                        if (event['description'] != null && (event['description'] as String).isNotEmpty) ...[
                                          const SizedBox(height: 3),
                                          Text(
                                            event['description'],
                                            style: const TextStyle(
                                              color: HudyatColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ] else ...[
                                          const SizedBox(height: 3),
                                          Text(
                                            DateFormat('EEEE, MMMM dd, yyyy').format(date),
                                            style: const TextStyle(
                                              color: HudyatColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                        if (cardTime != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            _formatTimeDisplay(cardTime),
                                            style: const TextStyle(
                                              color: HudyatColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded, color: HudyatColors.textSecondary, size: 18),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: HudyatColors.accent, size: 20),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          backgroundColor: HudyatColors.card,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                          title: const Text('Delete Event', style: TextStyle(color: HudyatColors.textPrimary, fontWeight: FontWeight.w700)),
                                          content: Text('Delete "${event['name']}"? This will also remove all its duty logs.', style: const TextStyle(color: HudyatColors.textSecondary)),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: HudyatColors.textSecondary))),
                                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: HudyatColors.accent, fontWeight: FontWeight.w700))),
                                          ],
                                        ),
                                      );
                                      if (confirm == true && context.mounted) {
                                        provider.deleteEvent(event['id'].toString());
                                      }
                                    },
                                  ),
                                ],
                              ),
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
