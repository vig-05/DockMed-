import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/medications_provider.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  final List<String> _frequencies = [
    'Once daily',
    'Twice daily',
    'Three times daily',
    'As needed'
  ];

  void _showAddMedicationSheet() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final notesController = TextEditingController();
    String selectedFrequency = 'Once daily';
    DateTime selectedDate = DateTime.now();

    final Map<String, bool> timeSlots = {
      'Morning': false,
      'Afternoon': false,
      'Evening': false,
      'Night': false,
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Add Medication',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Medication Name',
                        hintText: 'e.g., Amoxicillin',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: dosageController,
                      decoration: InputDecoration(
                        labelText: 'Dosage',
                        hintText: 'e.g., 500mg',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedFrequency,
                      decoration: InputDecoration(
                        labelText: 'Frequency',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _frequencies.map((v) {
                        return DropdownMenuItem<String>(
                            value: v, child: Text(v));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setSheetState(() => selectedFrequency = v);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Time Slots',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: timeSlots.keys.map((slot) {
                        return FilterChip(
                          label: Text(slot),
                          selected: timeSlots[slot]!,
                          onSelected: (selected) {
                            setSheetState(() => timeSlots[slot] = selected);
                          },
                          selectedColor:
                              AppTheme.primary.withValues(alpha: 0.2),
                          checkmarkColor: AppTheme.primary,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      readOnly: true,
                      controller: TextEditingController(
                          text: DateFormat('dd MMM yyyy')
                              .format(selectedDate)),
                      decoration: InputDecoration(
                        labelText: 'Start Date',
                        suffixIcon:
                            const Icon(Icons.calendar_today_rounded),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setSheetState(() => selectedDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Notes (Optional)',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.isEmpty ||
                              dosageController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please fill in name and dosage')),
                            );
                            return;
                          }
                          final med = Medication(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            name: nameController.text,
                            dosage: dosageController.text,
                            frequency: selectedFrequency,
                            timeSlots: timeSlots,
                            startDate: selectedDate,
                            notes: notesController.text,
                          );
                          Provider.of<MedicationsProvider>(context,
                                  listen: false)
                              .addMedication(med);
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
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProgressHeader(MedicationsProvider provider) {
    final total = provider.medications.length;
    final taken = provider.medications.where((m) => m.takenToday).length;
    final progress = total > 0 ? taken / total : 0.0;
    final allDone = taken == total;

    final progressColor = allDone
        ? AppTheme.success
        : taken > 0
            ? AppTheme.warning
            : AppTheme.primary;
    final progressLabel = allDone
        ? "All done! Great job today 🎉"
        : taken > 0
            ? "$taken of $total medications taken"
            : "No medications taken yet";

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: progressColor.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Progress",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$taken / $total',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppTheme.surface,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            progressLabel,
            style: TextStyle(
              fontSize: 13,
              color: progressColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(Medication med, MedicationsProvider provider) {
    final activeSlots = med.timeSlots.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .join(', ');
    final taken = med.takenToday;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: taken ? AppTheme.successLight : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: taken
              ? AppTheme.success.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: taken
                        ? AppTheme.success.withValues(alpha: 0.15)
                        : Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    taken
                        ? Icons.check_circle_rounded
                        : Icons.medication_liquid_rounded,
                    color: taken ? AppTheme.success : Colors.green,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med.name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: taken
                              ? AppTheme.success
                              : AppTheme.textPrimary,
                          decoration:
                              taken ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${med.dosage} • ${med.frequency}',
                        style: TextStyle(
                          fontSize: 13,
                          color: taken
                              ? AppTheme.success.withValues(alpha: 0.7)
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: taken,
                  onChanged: (val) => provider.toggleTakenToday(med.id, val),
                  activeThumbColor: AppTheme.success,
                  activeTrackColor: AppTheme.success.withValues(alpha: 0.3),
                ),
              ],
            ),
            if (activeSlots.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: taken
                      ? AppTheme.success.withValues(alpha: 0.08)
                      : AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 15,
                        color: taken
                            ? AppTheme.success
                            : AppTheme.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      activeSlots,
                      style: TextStyle(
                        fontSize: 13,
                        color: taken
                            ? AppTheme.success
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (med.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Note: ${med.notes}',
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: const BoxDecoration(
                color: AppTheme.surface, shape: BoxShape.circle),
            child: Icon(Icons.medication_rounded,
                size: 80, color: AppTheme.primary.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 24),
          const Text('No Medications Added',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to add medications\nand keep track of your doses.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicationsProvider>(
      builder: (context, provider, child) {
        if (!provider.isLoaded) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: const Text('My Medications',
                style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: provider.medications.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    _buildProgressHeader(provider),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                        itemCount: provider.medications.length,
                        itemBuilder: (context, index) {
                          final med = provider.medications[index];
                          return Dismissible(
                            key: Key(med.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) =>
                                provider.deleteMedication(med.id),
                            child: _buildMedicationCard(med, provider),
                          );
                        },
                      ),
                    ),
                  ],
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddMedicationSheet,
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
}
