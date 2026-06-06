// Modal bottom sheet with a wheel picker for choosing a break
// duration. Step is driven by [kTimeGranularityMin] in app_settings.dart
// so flipping that constant changes ALL minute pickers + rounding rules
// at once (1 = testing precision, 5 = production).
//
// Usage:
//   final newMin = await EditDurationSheet.show(context, slot.durationMinutes);
//   if (newMin != null) { /* apply */ }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/app_settings.dart';
import '../../theme/app_theme.dart';

class EditDurationSheet extends StatefulWidget {
  /// Currently-saved duration in minutes (initial wheel position).
  final int initialMinutes;

  const EditDurationSheet({super.key, required this.initialMinutes});

  /// Opens the sheet. Returns the selected minutes, or null if cancelled.
  static Future<int?> show(BuildContext context, int initial) {
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.paper,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => EditDurationSheet(initialMinutes: initial),
    );
  }

  @override
  State<EditDurationSheet> createState() => _EditDurationSheetState();
}

class _EditDurationSheetState extends State<EditDurationSheet> {
  // Picker values: step, 2*step, …, _maxMin. Step comes from the global
  // granularity constant — `kTimeGranularityMin = 1` shows every minute,
  // `5` shows the production 5-min ticks.
  int get _stepMin => kTimeGranularityMin;
  static const int _maxMin = 120;

  late int _selectedMin;
  late FixedExtentScrollController _ctrl;

  List<int> get _options =>
      List.generate(_maxMin ~/ _stepMin, (i) => (i + 1) * _stepMin);

  @override
  void initState() {
    super.initState();
    _selectedMin = widget.initialMinutes;
    final initialIndex = _options.indexOf(_selectedMin).clamp(0, _options.length - 1);
    _ctrl = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'Break duration',
              style: GoogleFonts.architectsDaughter(
                fontSize: 20,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '5-minute steps',
              style: GoogleFonts.patrickHand(
                fontSize: 12,
                color: AppColors.inkMuted,
              ),
            ),
            const SizedBox(height: 14),

            // The wheel
            SizedBox(
              height: 180,
              child: CupertinoPicker(
                scrollController: _ctrl,
                itemExtent: 40,
                magnification: 1.1,
                squeeze: 1.1,
                useMagnifier: true,
                selectionOverlay: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.ink, width: 1.5),
                      bottom: BorderSide(color: AppColors.ink, width: 1.5),
                    ),
                    color: AppColors.terracotta.withValues(alpha: 0.08),
                  ),
                ),
                onSelectedItemChanged: (i) => setState(() {
                  _selectedMin = _options[i];
                }),
                children: [
                  for (final m in _options)
                    Center(
                      child: Text(
                        '$m min',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 18,
                          color: AppColors.ink,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Cancel + Save buttons
            Row(
              children: [
                Expanded(
                  child: _SheetButton(
                    label: 'cancel',
                    primary: false,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SheetButton(
                    label: 'save',
                    primary: true,
                    onTap: () => Navigator.of(context).pop(_selectedMin),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final String label;
  final bool primary;
  final VoidCallback onTap;
  const _SheetButton({
    required this.label,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: primary ? AppColors.terracotta : Colors.transparent,
          border: Border.all(color: AppColors.ink, width: 2),
          borderRadius: BorderRadius.circular(10),
          boxShadow: primary
              ? const [
                  BoxShadow(
                    color: AppColors.ink,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.caveat(
              fontSize: 16,
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
