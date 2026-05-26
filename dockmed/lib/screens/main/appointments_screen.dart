import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/appointments_provider.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAppointmentSheet({Appointment? existing}) {
    final docCtrl = TextEditingController(text: existing?.doctorName ?? '');
    final specCtrl = TextEditingController(text: existing?.specialization ?? '');
    final hospCtrl = TextEditingController(text: existing?.hospital ?? '');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    DateTime selectedDate = existing?.dateTime ?? DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24, right: 24, top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(existing == null ? 'Book Appointment' : 'Reschedule',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary)),
                    IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 16),
                _sheetField(docCtrl, 'Doctor Name', 'e.g., Dr. Smith'),
                const SizedBox(height: 14),
                _sheetField(specCtrl, 'Specialization', 'e.g., Cardiologist'),
                const SizedBox(height: 14),
                _sheetField(hospCtrl, 'Hospital / Clinic', ''),
                const SizedBox(height: 14),
                TextField(
                  readOnly: true,
                  controller: TextEditingController(
                      text: DateFormat('dd MMM yyyy, hh:mm a')
                          .format(selectedDate)),
                  decoration: InputDecoration(
                    labelText: 'Date & Time',
                    suffixIcon: const Icon(Icons.calendar_today_rounded),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (date != null && context.mounted) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDate),
                      );
                      if (time != null) {
                        setSheet(() => selectedDate = DateTime(date.year,
                            date.month, date.day, time.hour, time.minute));
                      }
                    }
                  },
                ),
                const SizedBox(height: 14),
                _sheetField(notesCtrl, 'Notes (Optional)', '', maxLines: 2),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (docCtrl.text.isEmpty || hospCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content:
                                Text('Doctor and Hospital are required')));
                        return;
                      }
                      final appt = Appointment(
                        id: existing?.id ??
                            DateTime.now().millisecondsSinceEpoch.toString(),
                        doctorName: docCtrl.text,
                        specialization: specCtrl.text,
                        hospital: hospCtrl.text,
                        dateTime: selectedDate,
                        notes: notesCtrl.text,
                      );
                      final prov = Provider.of<AppointmentsProvider>(context,
                          listen: false);
                      if (existing != null) {
                        prov.updateAppointment(appt);
                      } else {
                        prov.addAppointment(appt);
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(existing == null ? 'Save' : 'Update',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sheetField(TextEditingController ctrl, String label, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint.isEmpty ? null : hint,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, Appointment appt, AppointmentsProvider prov) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content:
            const Text('Are you sure you want to cancel this appointment?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No')),
          TextButton(
            onPressed: () {
              prov.deleteAppointment(appt.id);
              Navigator.pop(context);
            },
            child: const Text('Yes, Cancel',
                style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppointmentsProvider>(
      builder: (context, provider, child) {
        if (!provider.isLoaded) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final now = DateTime.now();
        final upcoming =
            provider.appointments.where((a) => a.dateTime.isAfter(now)).toList();
        final past =
            provider.appointments.where((a) => a.dateTime.isBefore(now)).toList();

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop()),
            title: const Text('Appointments',
                style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.primary,
                  unselectedLabelColor: AppTheme.textSecondary,
                  indicatorColor: AppTheme.primary,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: [
                    Tab(text: 'Upcoming (${upcoming.length})'),
                    Tab(text: 'Past (${past.length})'),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildList(upcoming, false, provider),
              _buildList(past, true, provider),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAppointmentSheet(),
            backgroundColor: AppTheme.primary,
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child:
                const Icon(Icons.add_rounded, color: Colors.white, size: 32),
          ),
        );
      },
    );
  }

  Widget _buildList(
      List<Appointment> list, bool isPast, AppointmentsProvider provider) {
    if (list.isEmpty) return _buildEmptyState(isPast);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: list.length,
      itemBuilder: (context, index) =>
          _buildCard(list[index], index, isPast, provider),
    );
  }

  Widget _buildCard(Appointment appt, int index, bool isPast,
      AppointmentsProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isPast
                ? const Color(0xFFEAEFF2)
                : AppTheme.primary.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card header ──────────────────────────────────────
            Row(
              children: [
                Text(
                  '/${(index + 1).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isPast
                        ? Colors.grey.shade200
                        : AppTheme.textPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_rounded,
                      color: isPast ? Colors.grey : Colors.white, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Doctor info ──────────────────────────────────────
            Text(appt.doctorName,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isPast ? Colors.grey : AppTheme.textPrimary)),
            if (appt.specialization.isNotEmpty)
              Text(appt.specialization,
                  style: TextStyle(
                      fontSize: 13,
                      color: isPast ? Colors.grey.shade400 : AppTheme.primary,
                      fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),

            // ── Tags row ─────────────────────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _tag(Icons.location_on_rounded, appt.hospital, isPast),
                _tag(Icons.access_time_rounded,
                    DateFormat('dd MMM, hh:mm a').format(appt.dateTime), isPast),
                if (appt.notes.isNotEmpty)
                  _tag(Icons.notes_rounded, appt.notes, isPast),
              ],
            ),

            // ── Actions ──────────────────────────────────────────
            if (!isPast) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _showAppointmentSheet(existing: appt),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textPrimary,
                        side: const BorderSide(color: Color(0xFFEAEFF2)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('Reschedule',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _confirmDelete(context, appt, provider),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.danger,
                        side: BorderSide(
                            color: AppTheme.danger.withValues(alpha: 0.4)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tag(IconData icon, String label, bool isPast) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isPast ? Colors.grey.shade100 : AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isPast
                ? const Color(0xFFEAEFF2)
                : AppTheme.primaryLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 12,
              color: isPast ? Colors.grey.shade400 : AppTheme.primary),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 11,
                    color: isPast
                        ? Colors.grey.shade500
                        : AppTheme.primary,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isPast) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
                color: AppTheme.textPrimary, shape: BoxShape.circle),
            child: const Icon(Icons.calendar_month_rounded,
                color: Colors.white, size: 36),
          ),
          const SizedBox(height: 20),
          Text(isPast ? 'No Past Appointments' : 'No Upcoming Appointments',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text(
            isPast
                ? 'Your completed appointments will appear here.'
                : 'Tap + to book your first appointment.',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}
