import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../main.dart';
import '../../services/duty_service.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final _dutyService = DutyService();
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = true;
  bool _showInactive = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMembers();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    if (_searchQuery.isEmpty) return _members;
    return _members.where((m) {
      final name = (m['full_name'] as String? ?? '').toLowerCase();
      final id = (m['student_id'] as String? ?? '').toLowerCase();
      final course = (m['course'] as String? ?? '').toLowerCase();
      return name.contains(_searchQuery) ||
          id.contains(_searchQuery) ||
          course.contains(_searchQuery);
    }).toList();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    try {
      final members = await _dutyService.getMembers(showAll: _showInactive);
      if (mounted) setState(() { _members = members; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMemberProfile(Map<String, dynamic> member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MemberProfileSheet(member: member, service: _dutyService),
    );
  }

  void _showAddMemberSheet() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final studentIdController = TextEditingController();
    final passwordController = TextEditingController();
    final courseController = TextEditingController();
    final sectionController = TextEditingController();
    String selectedRole = 'member';
    String? selectedYearLevel;
    bool obscure = true;
    String? errorMsg;

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: HudyatColors.divider, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Add Member', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: HudyatColors.textPrimary)),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: HudyatColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Full Name *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: studentIdController,
                  style: const TextStyle(color: HudyatColors.textPrimary),
                  keyboardType: TextInputType.number,
                  inputFormatters: [_StudentIdFormatter()],
                  decoration: const InputDecoration(
                    labelText: 'Student ID',
                    hintText: '00-00000-000',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: courseController,
                  style: const TextStyle(color: HudyatColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Course (e.g. BS Information Technology)'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(color: HudyatColors.cardElevated, borderRadius: BorderRadius.circular(12)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: const Text('Year Level', style: TextStyle(color: HudyatColors.textSecondary, fontSize: 14)),
                            value: selectedYearLevel,
                            dropdownColor: HudyatColors.card,
                            isExpanded: true,
                            style: const TextStyle(color: HudyatColors.textPrimary),
                            items: const [
                              DropdownMenuItem(value: '1st Year', child: Text('1st Year')),
                              DropdownMenuItem(value: '2nd Year', child: Text('2nd Year')),
                              DropdownMenuItem(value: '3rd Year', child: Text('3rd Year')),
                              DropdownMenuItem(value: '4th Year', child: Text('4th Year')),
                            ],
                            onChanged: (val) => setSheetState(() => selectedYearLevel = val),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: sectionController,
                        style: const TextStyle(color: HudyatColors.textPrimary),
                        decoration: const InputDecoration(labelText: 'Section'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: HudyatColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Email Address *'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: obscure,
                  style: const TextStyle(color: HudyatColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Password *',
                    suffixIcon: IconButton(
                      icon: Icon(obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: HudyatColors.textSecondary, size: 18),
                      onPressed: () => setSheetState(() => obscure = !obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: HudyatColors.cardElevated, borderRadius: BorderRadius.circular(12)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedRole,
                      dropdownColor: HudyatColors.card,
                      isExpanded: true,
                      style: const TextStyle(color: HudyatColors.textPrimary),
                      items: const [
                        DropdownMenuItem(value: 'member', child: Text('Member')),
                        DropdownMenuItem(value: 'officer', child: Text('Officer')),
                      ],
                      onChanged: (val) => setSheetState(() => selectedRole = val!),
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
                      if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
                        setSheetState(() => errorMsg = 'Please fill all required fields (*)');
                        return;
                      }
                      try {
                        final response = await _dutyService.createMember(
                          fullName: nameController.text.trim(),
                          studentId: studentIdController.text.trim(),
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                          role: selectedRole,
                          course: courseController.text.trim(),
                          yearLevel: selectedYearLevel,
                          section: sectionController.text.trim(),
                        );
                        if (response['message'] != null && context.mounted) {
                          Navigator.pop(context);
                          await _loadMembers();
                        } else {
                          setSheetState(() => errorMsg = response['error'] ?? 'Failed to add member');
                        }
                      } catch (e) {
                        setSheetState(() => errorMsg = e.toString());
                      }
                    },
                    child: const Text('Add Member'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditMemberSheet(Map<String, dynamic> member) {
    final nameController = TextEditingController(text: member['full_name'] ?? '');
    final emailController = TextEditingController(text: member['email'] ?? '');
    final studentIdController = TextEditingController(text: member['student_id'] ?? '');
    final courseController = TextEditingController(text: member['course'] ?? '');
    final sectionController = TextEditingController(text: member['section'] ?? '');
    final passwordController = TextEditingController();
    String selectedRole = member['role'] ?? 'member';
    String? selectedYearLevel = (member['year_level'] as String?)?.isNotEmpty == true ? member['year_level'] : null;
    bool obscure = true;
    String? errorMsg;

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: HudyatColors.divider, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Edit Member', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: HudyatColors.textPrimary)),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: HudyatColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Full Name *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: studentIdController,
                  style: const TextStyle(color: HudyatColors.textPrimary),
                  keyboardType: TextInputType.number,
                  inputFormatters: [_StudentIdFormatter()],
                  decoration: const InputDecoration(
                    labelText: 'Student ID',
                    hintText: '00-00000-000',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: courseController,
                  style: const TextStyle(color: HudyatColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Course'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(color: HudyatColors.cardElevated, borderRadius: BorderRadius.circular(12)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: const Text('Year Level', style: TextStyle(color: HudyatColors.textSecondary, fontSize: 14)),
                            value: selectedYearLevel,
                            dropdownColor: HudyatColors.card,
                            isExpanded: true,
                            style: const TextStyle(color: HudyatColors.textPrimary),
                            items: const [
                              DropdownMenuItem(value: '1st Year', child: Text('1st Year')),
                              DropdownMenuItem(value: '2nd Year', child: Text('2nd Year')),
                              DropdownMenuItem(value: '3rd Year', child: Text('3rd Year')),
                              DropdownMenuItem(value: '4th Year', child: Text('4th Year')),
                            ],
                            onChanged: (val) => setSheetState(() => selectedYearLevel = val),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: sectionController,
                        style: const TextStyle(color: HudyatColors.textPrimary),
                        decoration: const InputDecoration(labelText: 'Section'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: HudyatColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Email Address *'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: obscure,
                  style: const TextStyle(color: HudyatColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'New Password (leave blank to keep)',
                    suffixIcon: IconButton(
                      icon: Icon(obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: HudyatColors.textSecondary, size: 18),
                      onPressed: () => setSheetState(() => obscure = !obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: HudyatColors.cardElevated, borderRadius: BorderRadius.circular(12)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedRole,
                      dropdownColor: HudyatColors.card,
                      isExpanded: true,
                      style: const TextStyle(color: HudyatColors.textPrimary),
                      items: const [
                        DropdownMenuItem(value: 'member', child: Text('Member')),
                        DropdownMenuItem(value: 'officer', child: Text('Officer')),
                      ],
                      onChanged: (val) => setSheetState(() => selectedRole = val!),
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
                      if (nameController.text.isEmpty || emailController.text.isEmpty) {
                        setSheetState(() => errorMsg = 'Full Name and Email are required');
                        return;
                      }
                      try {
                        final response = await _dutyService.updateMember(
                          id: member['id'].toString(),
                          fullName: nameController.text.trim(),
                          studentId: studentIdController.text.trim(),
                          email: emailController.text.trim(),
                          password: passwordController.text.trim().isEmpty ? null : passwordController.text.trim(),
                          role: selectedRole,
                          course: courseController.text.trim(),
                          yearLevel: selectedYearLevel,
                          section: sectionController.text.trim(),
                        );
                        if (response['message'] != null && context.mounted) {
                          Navigator.pop(context);
                          await _loadMembers();
                        } else {
                          setSheetState(() => errorMsg = response['error'] ?? 'Failed to update member');
                        }
                      } catch (e) {
                        setSheetState(() => errorMsg = e.toString());
                      }
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

  Color _avatarColor(String name) {
    const colors = [
      Color(0xFF5C6BC0), Color(0xFF26A69A), Color(0xFFEF6C00),
      Color(0xFF7B1FA2), Color(0xFF2E7D32), Color(0xFF00838F),
      Color(0xFFC62828), Color(0xFF4527A0),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Members',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: HudyatColors.textPrimary, letterSpacing: -0.5),
                      ),
                      if (!_isLoading)
                        Text(
                          '${_members.length} total',
                          style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 13),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() => _showInactive = !_showInactive);
                          _loadMembers();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _showInactive ? HudyatColors.textSecondary.withOpacity(0.15) : HudyatColors.cardElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _showInactive ? HudyatColors.textSecondary : HudyatColors.divider),
                          ),
                          child: Icon(
                            _showInactive ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: _showInactive ? HudyatColors.textSecondary : HudyatColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _showAddMemberSheet,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: HudyatColors.accent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: HudyatColors.accent.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
                          ),
                          child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Search bar ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: HudyatColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search by name, ID, or course…',
                  prefixIcon: const Icon(Icons.search_rounded, color: HudyatColors.textSecondary, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, color: HudyatColors.textSecondary, size: 18),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                ),
              ),
            ),

            // ── Results count when searching ────────────────────────────
            if (_searchQuery.isNotEmpty && !_isLoading)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  '${filtered.length} result${filtered.length != 1 ? 's' : ''} for "$_searchQuery"',
                  style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 12),
                ),
              ),

            // ── List ───────────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: HudyatColors.accent))
                  : filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.people_outline_rounded,
                                size: 56,
                                color: HudyatColors.textSecondary,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _searchQuery.isNotEmpty ? 'No members match "$_searchQuery"' : 'No members yet',
                                style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final member = filtered[index];
                            final isOfficer = member['role'] == 'officer';
                            final isActive = member['is_active'].toString() == '1';
                            final roleColor = isOfficer ? Colors.blueAccent : HudyatColors.accent;
                            final avatarColor = isActive ? _avatarColor(member['full_name'] ?? '') : HudyatColors.textSecondary;
                            final initials = (member['full_name'] as String? ?? 'M')
                                .split(' ')
                                .map((e) => e.isNotEmpty ? e[0] : '')
                                .take(2)
                                .join()
                                .toUpperCase();

                            return GestureDetector(
                              onTap: () => _showMemberProfile(member),
                              child: Opacity(
                                opacity: isActive ? 1.0 : 0.5,
                                child: Container(
                                padding: const EdgeInsets.all(14),
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
                                        color: avatarColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(initials, style: TextStyle(color: avatarColor, fontWeight: FontWeight.w700, fontSize: 15)),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            member['full_name'] ?? '',
                                            style: const TextStyle(color: HudyatColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            member['student_id'] ?? 'No Student ID',
                                            style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 12),
                                          ),
                                          if (member['course'] != null && (member['course'] as String).isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              [
                                                member['course'],
                                                if (member['year_level'] != null) member['year_level'],
                                                if (member['section'] != null && (member['section'] as String).isNotEmpty) '· Sec ${member['section']}',
                                              ].join(' '),
                                              style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 11),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (!isActive)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: HudyatColors.textSecondary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Text('Inactive', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: HudyatColors.textSecondary)),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: roleColor.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          isOfficer ? 'Officer' : 'Member',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: roleColor),
                                        ),
                                      ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) async {
                                        if (value == 'edit') {
                                          _showEditMemberSheet(member);
                                        } else if (value == 'deactivate') {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              backgroundColor: HudyatColors.card,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                              title: const Text('Deactivate Member', style: TextStyle(color: HudyatColors.textPrimary, fontWeight: FontWeight.w700)),
                                              content: Text('Deactivate "${member['full_name']}"? They won\'t appear in active lists but their records are preserved.', style: const TextStyle(color: HudyatColors.textSecondary)),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: HudyatColors.textSecondary))),
                                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Deactivate', style: TextStyle(color: HudyatColors.accent, fontWeight: FontWeight.w700))),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            await _dutyService.deactivateMember(member['id'].toString());
                                            await _loadMembers();
                                          }
                                        } else if (value == 'reactivate') {
                                          await _dutyService.reactivateMember(member['id'].toString());
                                          await _loadMembers();
                                        } else if (value == 'delete') {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              backgroundColor: HudyatColors.card,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                              title: const Text('Remove Member', style: TextStyle(color: HudyatColors.textPrimary, fontWeight: FontWeight.w700)),
                                              content: Text('Permanently remove "${member['full_name']}" and all their records? This cannot be undone.', style: const TextStyle(color: HudyatColors.textSecondary)),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: HudyatColors.textSecondary))),
                                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove', style: TextStyle(color: HudyatColors.accent, fontWeight: FontWeight.w700))),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            await _dutyService.deleteMember(member['id'].toString());
                                            await _loadMembers();
                                          }
                                        }
                                      },
                                      itemBuilder: (_) => [
                                        if (isActive) ...[
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(children: [
                                              Icon(Icons.edit_rounded, size: 16, color: HudyatColors.textSecondary),
                                              SizedBox(width: 10),
                                              Text('Edit', style: TextStyle(color: HudyatColors.textPrimary)),
                                            ]),
                                          ),
                                          const PopupMenuItem(
                                            value: 'deactivate',
                                            child: Row(children: [
                                              Icon(Icons.person_off_rounded, size: 16, color: HudyatColors.textSecondary),
                                              SizedBox(width: 10),
                                              Text('Deactivate', style: TextStyle(color: HudyatColors.textPrimary)),
                                            ]),
                                          ),
                                        ] else
                                          const PopupMenuItem(
                                            value: 'reactivate',
                                            child: Row(children: [
                                              Icon(Icons.person_rounded, size: 16, color: HudyatColors.textSecondary),
                                              SizedBox(width: 10),
                                              Text('Reactivate', style: TextStyle(color: HudyatColors.textPrimary)),
                                            ]),
                                          ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(children: [
                                            Icon(Icons.delete_outline_rounded, size: 16, color: HudyatColors.accent),
                                            SizedBox(width: 10),
                                            Text('Remove Permanently', style: TextStyle(color: HudyatColors.accent)),
                                          ]),
                                        ),
                                      ],
                                      color: HudyatColors.card,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      icon: const Icon(Icons.more_vert_rounded, color: HudyatColors.textSecondary, size: 20),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
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

// ── Member Profile Bottom Sheet ────────────────────────────────────────────────

class _MemberProfileSheet extends StatefulWidget {
  final Map<String, dynamic> member;
  final DutyService service;

  const _MemberProfileSheet({required this.member, required this.service});

  @override
  State<_MemberProfileSheet> createState() => _MemberProfileSheetState();
}

class _MemberProfileSheetState extends State<_MemberProfileSheet> {
  Map<String, dynamic>? _perf;
  bool _loadingPerf = true;

  @override
  void initState() {
    super.initState();
    _loadPerf();
  }

  Future<void> _loadPerf() async {
    final perf = await widget.service.getMemberPerformance(widget.member['id'].toString());
    if (mounted) setState(() { _perf = perf; _loadingPerf = false; });
  }

  Color _classColor(String? c) {
    switch (c) {
      case 'Highly Active': return HudyatColors.success;
      case 'Moderately Active': return HudyatColors.warning;
      case 'Low Participation': return HudyatColors.accent;
      default: return HudyatColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.member;
    final isOfficer = m['role'] == 'officer';
    final roleColor = isOfficer ? Colors.blueAccent : HudyatColors.accent;
    final name = m['full_name'] as String? ?? 'Unknown';
    final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
    final cls = _perf?['classification'] as String?;
    final clsColor = _classColor(cls);

    return Container(
      decoration: const BoxDecoration(
        color: HudyatColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: HudyatColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),

            // Avatar + name
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(initials, style: TextStyle(color: roleColor, fontWeight: FontWeight.w800, fontSize: 22)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(color: HudyatColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 20)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isOfficer ? 'Officer' : 'Member',
                          style: TextStyle(color: roleColor, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Info section
            _sectionLabel('Student Information'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: HudyatColors.cardElevated,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _InfoRow(icon: Icons.badge_rounded, label: 'Student ID', value: m['student_id'] ?? 'Not set'),
                  _InfoRow(icon: Icons.email_rounded, label: 'Email', value: m['email'] ?? 'Not set'),
                  _InfoRow(icon: Icons.school_rounded, label: 'Course', value: m['course'] ?? 'Not set'),
                  _InfoRow(icon: Icons.calendar_today_rounded, label: 'Year Level', value: m['year_level'] ?? 'Not set'),
                  _InfoRow(icon: Icons.group_rounded, label: 'Section', value: (m['section'] != null && (m['section'] as String).isNotEmpty) ? m['section'] : 'Not set', isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Performance section
            _sectionLabel('Performance'),
            const SizedBox(height: 10),
            _loadingPerf
                ? const Center(child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: HudyatColors.accent, strokeWidth: 2),
                  ))
                : _perf == null
                    ? const Text('No performance data.', style: TextStyle(color: HudyatColors.textSecondary))
                    : Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: clsColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: clsColor.withOpacity(0.3)),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  cls ?? 'No Data Yet',
                                  style: TextStyle(color: clsColor, fontSize: 16, fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 2),
                                const Text('Classification', style: TextStyle(color: HudyatColors.textSecondary, fontSize: 12)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _PerfCard(
                                label: 'Total Duties',
                                value: '${_perf!['total_duties'] ?? 0}',
                                color: HudyatColors.accent,
                              ),
                              const SizedBox(width: 10),
                              _PerfCard(
                                label: 'Avg / Month',
                                value: '${double.tryParse(_perf!['avg_duties_per_month'].toString())?.toStringAsFixed(1) ?? '0'}',
                                color: HudyatColors.success,
                              ),
                            ],
                          ),
                        ],
                      ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({required this.icon, required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 15, color: HudyatColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(color: HudyatColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 12),
          const Divider(color: HudyatColors.divider, height: 1),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _PerfCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _PerfCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: HudyatColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// Formats input as XX-XXXXX-XXX (student ID mask)
class _StudentIdFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Strip everything except digits
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Cap at 10 digits (2 + 5 + 3)
    final limited = digits.length > 10 ? digits.substring(0, 10) : digits;

    // Rebuild formatted string: XX-XXXXX-XXX
    final buffer = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      if (i == 2 || i == 7) buffer.write('-');
      buffer.write(limited[i]);
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
