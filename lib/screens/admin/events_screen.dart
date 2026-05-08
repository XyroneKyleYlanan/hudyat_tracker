import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
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
    Future.microtask(() => context.read<EventProvider>().loadEvents());
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

  void _showEventDetail(Map<String, dynamic> event) {
    final date = DateTime.parse(event['event_date']);
    final description = event['description'] as String? ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: HudyatColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
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
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
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
                        event['name'] ?? '',
                        style: const TextStyle(color: HudyatColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE, MMMM dd, yyyy').format(date),
                        style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'DESCRIPTION',
                style: TextStyle(color: HudyatColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: HudyatColors.cardElevated,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  description,
                  style: const TextStyle(color: HudyatColors.textPrimary, fontSize: 14, height: 1.6),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showCreateEventSheet() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    DateTime? selectedDate = _selectedDay;

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
                            return GestureDetector(
                              onTap: () => _showEventDetail(event),
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
