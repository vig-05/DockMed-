import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../providers/appointments_provider.dart';
import '../../providers/medications_provider.dart';
import '../../providers/vitals_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning,';
    if (h < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  int _computeScore(UserProvider user, VitalsProvider vitals, MedicationsProvider meds) {
    int s = 0;
    if (user.name != 'Guest' && user.name.isNotEmpty) s += 15;
    if (user.bloodGroup.isNotEmpty && user.bloodGroup != 'Not set') s += 15;
    if (user.height.isNotEmpty && user.height != '0') s += 10;
    if (user.emergencyName.isNotEmpty && user.emergencyName != 'Not set') s += 10;
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    if (vitals.readings.any((r) => r.date.isAfter(cutoff))) s += 25;
    if (meds.medications.isNotEmpty) {
      final taken = meds.medications.where((m) => m.takenToday).length;
      s += ((taken / meds.medications.length) * 25).round();
    }
    return s.clamp(0, 100);
  }

  static const List<String> _tips = [
    'Drink at least 8 glasses of water today to stay properly hydrated.',
    'A 30-minute walk can significantly improve your cardiovascular health.',
    'Aim for 7–9 hours of sleep tonight to help your body recover.',
    'Take your medications at the same time each day for best results.',
    'Eating colorful fruits and vegetables provides essential vitamins.',
    'Deep breathing exercises can help reduce stress and anxiety.',
    'Regular health checkups can detect issues before they become serious.',
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final appts = context.watch<AppointmentsProvider>();
    final meds = context.watch<MedicationsProvider>();
    final vitals = context.watch<VitalsProvider>();

    final firstName = (user.name == 'Guest' || user.name.isEmpty)
        ? 'there'
        : user.name.split(' ').first;
    final score = _computeScore(user, vitals, meds);
    final scoreLabel = score >= 75 ? 'Excellent' : score >= 50 ? 'Good' : 'Needs Attention';
    final scoreColor = score >= 75 ? AppTheme.success : score >= 50 ? AppTheme.warning : AppTheme.danger;

    final now = DateTime.now();
    final upcoming = appts.appointments.where((a) => a.dateTime.isAfter(now)).toList();
    final nextAppt = upcoming.isNotEmpty ? upcoming.first : null;
    final latestVital = vitals.readings.isNotEmpty ? vitals.readings.first : null;
    final tip = _tips[now.weekday % _tips.length];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_getGreeting(),
                          style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500)),
                      Text(
                        firstName == 'there' ? 'Welcome back!' : firstName,
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _circleBtn(Icons.notifications_outlined, () {}),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => context.push('/profile'),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              shape: BoxShape.circle),
                          child: const Icon(Icons.person_rounded,
                              color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Hero Card ─────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.textPrimary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Your Health,',
                              style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.2)),
                          const Text('One Place.',
                              style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accent,
                                  height: 1.2)),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('$score / 100',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: scoreColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(scoreLabel,
                                    style: TextStyle(
                                        color: scoreColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: score / 100,
                            strokeWidth: 6,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                scoreColor),
                          ),
                          Text('$score',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Quick Stat Row ─────────────────────────────────────────
              Row(
                children: [
                  _statChip(context, Icons.calendar_month_rounded,
                      '${upcoming.length}', 'Appts', '/appointments'),
                  const SizedBox(width: 10),
                  _statChip(context, Icons.medication_rounded,
                      '${meds.medications.length}', 'Meds', '/medication'),
                  const SizedBox(width: 10),
                  _statChip(
                    context,
                    Icons.monitor_heart_rounded,
                    latestVital?.displayValue ?? '--',
                    latestVital?.type ?? 'Vitals',
                    '/body',
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Quick Access Grid ──────────────────────────────────────
              _sectionHeader('Quick Access'),
              const SizedBox(height: 14),
              _buildServiceGrid(context),

              // ── Next Appointment ───────────────────────────────────────
              if (nextAppt != null) ...[
                const SizedBox(height: 32),
                _sectionHeader('Next Appointment'),
                const SizedBox(height: 14),
                _buildNextAppt(context, nextAppt),
              ],

              // ── Today's Medications ────────────────────────────────────
              if (meds.medications.isNotEmpty) ...[
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionHeader("Today's Medications"),
                    GestureDetector(
                      onTap: () => context.go('/medication'),
                      child: Text(
                        '${meds.medications.where((m) => m.takenToday).length}/${meds.medications.length} taken  →',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...meds.medications.take(3).map((med) => _medTile(med, meds)),
                if (meds.medications.length > 3)
                  GestureDetector(
                    onTap: () => context.go('/medication'),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Center(
                        child: Text('View all medications →',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
              ],

              // ── Health Tip ─────────────────────────────────────────────
              const SizedBox(height: 32),
              _buildTip(tip),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/app/emergency'),
        backgroundColor: AppTheme.danger,
        elevation: 6,
        icon: const Icon(Icons.sos_rounded, color: Colors.white),
        label: const Text('SOS',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2)),
      ),
    );
  }

  // ── Shared helpers ──────────────────────────────────────────────────────

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFEAEFF2)),
          boxShadow: [
            BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
    );
  }

  Widget _statChip(BuildContext context, IconData icon, String value,
      String label, String route) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.go(route),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEAEFF2)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: const BoxDecoration(
                    color: AppTheme.surface, shape: BoxShape.circle),
                child: Icon(icon, color: AppTheme.primary, size: 18),
              ),
              const SizedBox(height: 7),
              Text(value,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Text(label,
                  style: const TextStyle(
                      fontSize: 10, color: AppTheme.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary));
  }

  // ── Service Cards Grid (MediCareX style) ──────────────────────────────────

  Widget _buildServiceGrid(BuildContext context) {
    final cards = [
      {
        'num': '/01',
        'title': 'Records',
        'icon': Icons.folder_shared_rounded,
        'route': '/records',
        'tags': ['Lab Reports', 'Prescriptions'],
      },
      {
        'num': '/02',
        'title': 'Body & Vitals',
        'icon': Icons.favorite_rounded,
        'route': '/body',
        'tags': ['Blood Pressure', 'Heart Rate'],
      },
      {
        'num': '/03',
        'title': 'Medications',
        'icon': Icons.medication_rounded,
        'route': '/medication',
        'tags': ['Daily Dose', 'Schedule'],
      },
      {
        'num': '/04',
        'title': 'Appointments',
        'icon': Icons.calendar_today_rounded,
        'route': '/appointments',
        'tags': ['Upcoming', 'History'],
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.88,
      ),
      itemCount: cards.length,
      itemBuilder: (context, i) {
        final c = cards[i];
        final tags = c['tags'] as List<String>;
        return GestureDetector(
          onTap: () => context.push(c['route'] as String),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEAEFF2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(c['num'] as String,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500)),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                          color: AppTheme.textPrimary, shape: BoxShape.circle),
                      child: Icon(c['icon'] as IconData,
                          color: Colors.white, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(c['title'] as String,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: tags
                      .map((t) => _featureTag(t))
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _featureTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_rounded, size: 11, color: AppTheme.primary),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Next Appointment ──────────────────────────────────────────────────────

  Widget _buildNextAppt(BuildContext context, Appointment appt) {
    return GestureDetector(
      onTap: () => context.go('/appointments'),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEAEFF2)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                  color: AppTheme.textPrimary, shape: BoxShape.circle),
              child: const Icon(Icons.person_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appt.doctorName,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary)),
                  if (appt.specialization.isNotEmpty)
                    Text(appt.specialization,
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.primary)),
                  const SizedBox(height: 6),
                  _featureTag(
                      DateFormat('dd MMM, hh:mm a').format(appt.dateTime)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  // ── Today's Meds ─────────────────────────────────────────────────────────

  Widget _medTile(Medication med, MedicationsProvider provider) {
    final taken = med.takenToday;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: taken ? AppTheme.successLight : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: taken
                ? AppTheme.success.withValues(alpha: 0.3)
                : const Color(0xFFEAEFF2)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: taken
                    ? AppTheme.success.withValues(alpha: 0.15)
                    : AppTheme.surface,
                shape: BoxShape.circle),
            child: Icon(
              taken ? Icons.check_rounded : Icons.medication_rounded,
              color: taken ? AppTheme.success : AppTheme.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: taken ? AppTheme.success : AppTheme.textPrimary,
                      decoration: taken ? TextDecoration.lineThrough : null,
                    )),
                Text('${med.dosage} • ${med.frequency}',
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: taken,
            onChanged: (val) => provider.toggleTakenToday(med.id, val),
            activeThumbColor: AppTheme.success,
            activeTrackColor: AppTheme.success.withValues(alpha: 0.3),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  // ── Health Tip ────────────────────────────────────────────────────────────

  Widget _buildTip(String tip) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAEFF2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
                color: AppTheme.textPrimary, shape: BoxShape.circle),
            child:
                const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daily Health Tip',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Text(tip,
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
