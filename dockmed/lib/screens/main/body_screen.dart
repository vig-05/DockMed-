import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../providers/vitals_provider.dart';

class VitalStatus {
  final Color color;
  final String label;
  const VitalStatus(this.color, this.label);
}

class BodyScreen extends StatelessWidget {
  const BodyScreen({super.key});

  void _showAddVitalSheet(BuildContext context, String type, String unit) {
    final valueController = TextEditingController();
    DateTime selectedDate = DateTime.now();

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Add $type',
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
              TextField(
                controller: valueController,
                keyboardType: type == 'Blood Pressure'
                    ? TextInputType.text
                    : const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Value ($unit)',
                  hintText: type == 'Blood Pressure' ? 'e.g., 120/80' : 'Enter value',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
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
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (valueController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please enter a value')));
                      return;
                    }
                    double n1 = 0.0;
                    double? n2;
                    if (type == 'Blood Pressure') {
                      final parts = valueController.text.split('/');
                      if (parts.length == 2) {
                        n1 = double.tryParse(parts[0]) ?? 0.0;
                        n2 = double.tryParse(parts[1]) ?? 0.0;
                      }
                    } else {
                      n1 = double.tryParse(valueController.text) ?? 0.0;
                    }
                    Provider.of<VitalsProvider>(context, listen: false)
                        .addReading(VitalReading(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      type: type,
                      displayValue: valueController.text,
                      numericValue: n1,
                      numericValue2: n2,
                      date: selectedDate,
                    ));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);

    return Consumer<VitalsProvider>(
      builder: (context, provider, child) {
        if (!provider.isLoaded) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final vitals = [
          {
            'num': '/01',
            'type': 'Blood Pressure',
            'unit': 'mmHg',
            'icon': Icons.favorite_rounded,
            'reading': provider.getLatest('Blood Pressure'),
          },
          {
            'num': '/02',
            'type': 'Heart Rate',
            'unit': 'bpm',
            'icon': Icons.monitor_heart_rounded,
            'reading': provider.getLatest('Heart Rate'),
          },
          {
            'num': '/03',
            'type': 'Blood Glucose',
            'unit': 'mg/dL',
            'icon': Icons.water_drop_rounded,
            'reading': provider.getLatest('Blood Glucose'),
          },
          {
            'num': '/04',
            'type': 'Oxygen Level',
            'unit': '%',
            'icon': Icons.air_rounded,
            'reading': provider.getLatest('Oxygen Level'),
          },
          {
            'num': '/05',
            'type': 'Temperature',
            'unit': '°F',
            'icon': Icons.thermostat_rounded,
            'reading': provider.getLatest('Temperature'),
          },
          {
            'num': '/06',
            'type': 'Weight',
            'unit': 'kg',
            'icon': Icons.scale_rounded,
            'reading': provider.getLatest('Weight'),
          },
        ];

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop()),
            title: const Text('My Body',
                style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Section header ──────────────────────────────
                const Text('Current Vitals',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 14),

                // ── Vitals grid ─────────────────────────────────
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: vitals.length,
                  itemBuilder: (context, i) {
                    final v = vitals[i];
                    final reading = v['reading'] as VitalReading?;
                    final hasData = reading != null;
                    return _vitalCard(
                      context,
                      num: v['num'] as String,
                      type: v['type'] as String,
                      unit: v['unit'] as String,
                      icon: v['icon'] as IconData,
                      value: reading?.displayValue ?? '--',
                      hasData: hasData,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // ── Trends button ───────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/app/vitals'),
                    icon: const Icon(Icons.show_chart_rounded),
                    label: const Text('View Detailed Trends',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Body measurements ───────────────────────────
                const Text('Body Measurements',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEAEFF2)),
                  ),
                  child: Column(
                    children: [
                      _measureRow('/01', 'Height',
                          user.height.isEmpty || user.height == '0'
                              ? '--'
                              : '${user.height} cm',
                          isFirst: true),
                      _measureRow('/02', 'Weight',
                          user.weight.isEmpty || user.weight == '0'
                              ? '--'
                              : '${user.weight} kg'),
                      _measureRow('/03', 'BMI',
                          user.bmi > 0
                              ? user.bmi.toStringAsFixed(1)
                              : '--',
                          isLast: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _vitalCard(
    BuildContext context, {
    required String num,
    required String type,
    required String unit,
    required IconData icon,
    required String value,
    required bool hasData,
  }) {
    return GestureDetector(
      onTap: () => _showAddVitalSheet(context, type, unit),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: hasData
                  ? AppTheme.primary.withValues(alpha: 0.2)
                  : const Color(0xFFEAEFF2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(num,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500)),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: hasData ? AppTheme.textPrimary : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon,
                      color: hasData ? Colors.white : Colors.grey,
                      size: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(type,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: hasData
                            ? AppTheme.textPrimary
                            : Colors.grey.shade400)),
                if (hasData) ...[
                  const SizedBox(width: 3),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(unit,
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textSecondary)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: hasData
                    ? AppTheme.primary.withValues(alpha: 0.08)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hasData ? Icons.check_rounded : Icons.add_rounded,
                    size: 11,
                    color: hasData ? AppTheme.primary : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    hasData ? 'Logged' : 'Tap to add',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: hasData ? AppTheme.primary : Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _measureRow(String num, String label, String value,
      {bool isFirst = false, bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Text(num,
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500)),
              const SizedBox(width: 10),
              Text(label,
                  style: const TextStyle(
                      fontSize: 15, color: AppTheme.textSecondary)),
              const Spacer(),
              Text(value,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 18, endIndent: 18),
      ],
    );
  }
}
