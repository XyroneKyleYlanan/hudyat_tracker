import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/duty_provider.dart';
import '../../providers/event_provider.dart';
import '../../main.dart';

class DutiesScreen extends StatefulWidget {
  const DutiesScreen({super.key});

  @override
  State<DutiesScreen> createState() => _DutiesScreenState();
}

class _DutiesScreenState extends State<DutiesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DutyProvider>().loadAllDuties();
      context.read<DutyProvider>().loadMembers();
      context.read<EventProvider>().loadEvents();
    });
  }

  List<Map<String, dynamic>> _groupByEvent(List<Map<String, dynamic>> duties) {
    final Map<String, Map<String, dynamic>> groups = {};
    for (final duty in duties) {
      final eventId = duty['event_id']?.toString() ?? '';
      if (!groups.containsKey(eventId)) {
        groups[eventId] = {
          'event_id': eventId,
          'event_name': duty['event_name'] ?? '',
          'event_date': duty['event_date'],
          'duties': <Map<String, dynamic>>[],
        };
      }
      (groups[eventId]!['duties'] as List<Map<String, dynamic>>).add(duty);
    }
    final sorted = groups.values.toList();
    sorted.sort((a, b) {
      final aDate = a['event_date'] as String? ?? '';
      final bDate = b['event_date'] as String? ?? '';
      return bDate.compareTo(aDate);
    });
    return sorted;
  }

  Color _avatarColor(String name) {
    const colors = [
      Color(0xFF5C6BC0), Color(0xFF26A69A), Color(0xFFEF6C00),
      Color(0xFF7B1FA2), Color(0xFF2E7D32), Color(0xFF00838F),
      Color(0xFFC62828), Color(0xFF4527A0),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  void _showEventDuties(Map<String, dynamic> group) {
    final eventName = group['event_name'] as String;
    final eventDate = group['event_date'] as String?;
    final eventId = group['event_id'] as String;
    final date = eventDate != null ? DateTime.parse(eventDate) : null;

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
              height: MediaQuery.of(context).size.height * 0.75,
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (date != null)
                          Container(
                            width: 52, height: 52,
                            decoration: BoxDecoration(
                              color: HudyatColors.accent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('d').format(date),
                                  style: const TextStyle(color: HudyatColors.accent, fontSize: 20, fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  DateFormat('MMM').format(date).toUpperCase(),
                                  style: const TextStyle(color: HudyatColors.accent, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                eventName,
                                style: const TextStyle(color: HudyatColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 18),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                date != null
                                    ? '${DateFormat('MMMM dd, yyyy').format(date)} · ${duties.length} member${duties.length == 1 ? '' : 's'}'
                                    : '${duties.length} member${duties.length == 1 ? '' : 's'}',
                                style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: HudyatColors.divider, height: 1),
                  Expanded(
                    child: duties.isEmpty
                        ? const Center(
                            child: Text('No duties logged for this event.', style: TextStyle(color: HudyatColors.textSecondary)),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                            itemCount: duties.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (_, i) {
                              final duty = duties[i];
                              final memberName = duty['member_name'] as String? ?? 'Unknown';
                              final initials = memberName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
                              final avatarColor = _avatarColor(memberName);
                              final notes = duty['notes'] as String? ?? '';

                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: HudyatColors.cardElevated,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40, height: 40,
                                      decoration: BoxDecoration(
                                        color: avatarColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(initials, style: TextStyle(color: avatarColor, fontWeight: FontWeight.w700, fontSize: 13)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(memberName, style: const TextStyle(color: HudyatColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: avatarColor.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              duty['role_assigned'] ?? '',
                                              style: TextStyle(color: avatarColor, fontSize: 11, fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          if (notes.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              notes,
                                              style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 12, fontStyle: FontStyle.italic),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert_rounded, color: HudyatColors.textSecondary, size: 18),
                                      color: HudyatColors.cardElevated,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      padding: EdgeInsets.zero,
                                      onSelected: (value) async {
                                        if (value == 'edit') {
                                          _showEditDutySheet(duty, memberName);
                                        } else if (value == 'delete') {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              backgroundColor: HudyatColors.card,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                              title: const Text('Delete Duty Log', style: TextStyle(color: HudyatColors.textPrimary, fontWeight: FontWeight.w700)),
                                              content: Text('Remove $memberName\'s duty for "$eventName"?', style: const TextStyle(color: HudyatColors.textSecondary)),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: HudyatColors.textSecondary))),
                                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: HudyatColors.accent, fontWeight: FontWeight.w700))),
                                              ],
                                            ),
                                          );
                                          if (confirm == true && mounted) {
                                            provider.deleteDuty(duty['id'].toString());
                                          }
                                        }
                                      },
                                      itemBuilder: (_) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(children: [
                                            Icon(Icons.edit_rounded, size: 16, color: HudyatColors.textSecondary),
                                            SizedBox(width: 10),
                                            Text('Edit', style: TextStyle(color: HudyatColors.textPrimary, fontSize: 14)),
                                          ]),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(children: [
                                            Icon(Icons.delete_outline_rounded, size: 16, color: HudyatColors.accent),
                                            SizedBox(width: 10),
                                            Text('Delete', style: TextStyle(color: HudyatColors.accent, fontSize: 14)),
                                          ]),
                                        ),
                                      ],
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

  void _showEditDutySheet(Map<String, dynamic> duty, String memberName) {
    final roleController = TextEditingController(text: duty['role_assigned'] ?? '');
    final notesController = TextEditingController(text: duty['notes'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: HudyatColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 12,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: HudyatColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Edit Duty Log', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: HudyatColors.textPrimary, letterSpacing: -0.3)),
            const SizedBox(height: 4),
            Text(memberName, style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 14)),
            Text(duty['event_name'] ?? '', style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 13)),
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
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  if (roleController.text.trim().isEmpty) return;
                  final success = await context.read<DutyProvider>().updateDuty(
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
    );
  }

  void _showSearchPicker({
    required BuildContext sheetContext,
    required StateSetter setSheetState,
    required String title,
    required List<String> names,
    required List<String> ids,
    required String? selectedId,
    required void Function(String id, String name) onSelect,
  }) {
    String query = '';
    showModalBottomSheet(
      context: sheetContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setPickerState) {
          final indices = List.generate(names.length, (i) => i)
              .where((i) => query.isEmpty || names[i].toLowerCase().contains(query.toLowerCase()))
              .toList();
          return Container(
            height: MediaQuery.of(sheetContext).size.height * 0.6,
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
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: HudyatColors.textPrimary)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: TextField(
                    autofocus: true,
                    style: const TextStyle(color: HudyatColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search_rounded, color: HudyatColors.textSecondary, size: 20),
                    ),
                    onChanged: (val) => setPickerState(() => query = val),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                    itemCount: indices.length,
                    itemBuilder: (_, i) {
                      final idx = indices[i];
                      final isSelected = ids[idx] == selectedId;
                      return ListTile(
                        title: Text(
                          names[idx],
                          style: TextStyle(
                            color: HudyatColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_rounded, color: HudyatColors.accent, size: 18)
                            : null,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        onTap: () {
                          setSheetState(() => onSelect(ids[idx], names[idx]));
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLogDutySheet() {
    String? selectedMemberId;
    String? selectedMemberName;
    String? selectedEventId;
    String? selectedEventName;
    final roleController = TextEditingController();
    final notesController = TextEditingController();

    final dutyProvider = context.read<DutyProvider>();
    final eventProvider = context.read<EventProvider>();

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
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: HudyatColors.divider, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Log Duty', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: HudyatColors.textPrimary, letterSpacing: -0.3)),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _showSearchPicker(
                    sheetContext: ctx,
                    setSheetState: setSheetState,
                    title: 'Select Member',
                    names: dutyProvider.members.map((m) => m['full_name'] as String? ?? '').toList(),
                    ids: dutyProvider.members.map((m) => m['id'].toString()).toList(),
                    selectedId: selectedMemberId,
                    onSelect: (id, name) { selectedMemberId = id; selectedMemberName = name; },
                  ),
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
                GestureDetector(
                  onTap: () => _showSearchPicker(
                    sheetContext: ctx,
                    setSheetState: setSheetState,
                    title: 'Select Event',
                    names: eventProvider.events.map((e) => e['name'] as String? ?? '').toList(),
                    ids: eventProvider.events.map((e) => e['id'].toString()).toList(),
                    selectedId: selectedEventId,
                    onSelect: (id, name) { selectedEventId = id; selectedEventName = name; },
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(color: HudyatColors.cardElevated, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedEventName ?? 'Select Event',
                            style: TextStyle(color: selectedEventName != null ? HudyatColors.textPrimary : HudyatColors.textSecondary),
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
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (selectedMemberId == null || selectedEventId == null || roleController.text.isEmpty) return;
                      final success = await context.read<DutyProvider>().logDuty(
                        memberId: selectedMemberId!,
                        eventId: selectedEventId!,
                        roleAssigned: roleController.text.trim(),
                        notes: notesController.text.trim(),
                      );
                      if (success && ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Log Duty'),
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
    final provider = context.watch<DutyProvider>();
    final allGroups = _groupByEvent(provider.duties);
    final groups = _searchQuery.isEmpty
        ? allGroups
        : allGroups.where((g) => (g['event_name'] as String).toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Duty Logs',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: HudyatColors.textPrimary, letterSpacing: -0.5),
                  ),
                  GestureDetector(
                    onTap: _showLogDutySheet,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: HudyatColors.accent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: HudyatColors.accent.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: HudyatColors.textPrimary, fontSize: 14),
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Filter by event name...',
                  prefixIcon: const Icon(Icons.search_rounded, color: HudyatColors.textSecondary, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, color: HudyatColors.textSecondary, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),
            if (!provider.isLoading && provider.duties.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Text(
                  _searchQuery.isEmpty
                      ? '${allGroups.length} event${allGroups.length == 1 ? '' : 's'} · ${provider.duties.length} duties'
                      : '${groups.length} result${groups.length == 1 ? '' : 's'}',
                  style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 13),
                ),
              ),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: HudyatColors.accent))
                  : groups.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.assignment_outlined, size: 56, color: HudyatColors.textSecondary),
                              SizedBox(height: 12),
                              Text('No duties logged yet', style: TextStyle(color: HudyatColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w500)),
                              SizedBox(height: 4),
                              Text('Tap + to log the first duty', style: TextStyle(color: HudyatColors.textSecondary, fontSize: 13)),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          itemCount: groups.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final group = groups[index];
                            final eventName = group['event_name'] as String;
                            final eventDate = group['event_date'] as String?;
                            final duties = group['duties'] as List<Map<String, dynamic>>;
                            final date = eventDate != null ? DateTime.parse(eventDate) : null;

                            return GestureDetector(
                              onTap: () => _showEventDuties(group),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: HudyatColors.card,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: HudyatColors.divider),
                                ),
                                child: Row(
                                  children: [
                                    if (date != null)
                                      Container(
                                        width: 48, height: 48,
                                        decoration: BoxDecoration(
                                          color: HudyatColors.accent.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              DateFormat('d').format(date),
                                              style: const TextStyle(color: HudyatColors.accent, fontSize: 17, fontWeight: FontWeight.w800),
                                            ),
                                            Text(
                                              DateFormat('MMM').format(date).toUpperCase(),
                                              style: const TextStyle(color: HudyatColors.accent, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5),
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
                                            eventName,
                                            style: const TextStyle(color: HudyatColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${duties.length} member${duties.length == 1 ? '' : 's'} logged',
                                            style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right_rounded, color: HudyatColors.textSecondary, size: 20),
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
