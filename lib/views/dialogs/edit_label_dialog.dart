// AlertDialog with a single TextField — used to rename a break slot's
// label ("Morning Break", "Lunch Break", etc.)
//
// Usage:
//   final newName = await showEditLabelDialog(context, slot.label);
//   if (newName != null) { /* apply */ }

import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';

Future<String?> showEditLabelDialog(
  BuildContext context,
  String initialLabel,
) {
  return showDialog<String>(
    context: context,
    builder: (_) => _EditLabelDialog(initialLabel: initialLabel),
  );
}

class _EditLabelDialog extends StatefulWidget {
  final String initialLabel;
  const _EditLabelDialog({required this.initialLabel});

  @override
  State<_EditLabelDialog> createState() => _EditLabelDialogState();
}

class _EditLabelDialogState extends State<_EditLabelDialog> {
  late final TextEditingController _ctrl;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialLabel);
    _focus = FocusNode();
    // Auto-focus + select all on open so the user can just type
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focus.requestFocus();
      _ctrl.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _ctrl.text.length,
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _save() {
    final v = _ctrl.text.trim();
    if (v.isEmpty) return; // ignore empty
    Navigator.of(context).pop(v);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: AppColors.paperLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: AppColors.ink, width: 2),
      ),
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
      contentPadding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
      title: Text(
        l10n.edit_label_dialog_title,
        style: GoogleFonts.architectsDaughter(
          fontSize: 18,
          color: AppColors.ink,
        ),
      ),
      content: TextField(
        controller: _ctrl,
        focusNode: _focus,
        maxLength: 30,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _save(),
        style: GoogleFonts.patrickHand(
          fontSize: 16,
          color: AppColors.ink,
        ),
        decoration: InputDecoration(
          isDense: true,
          counterText: '',
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.inkHairline, width: 1.5),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.terracotta, width: 2),
          ),
          hintText: l10n.edit_label_dialog_hint,
          hintStyle: GoogleFonts.patrickHand(
            fontSize: 16,
            color: AppColors.inkHairline,
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            l10n.cancel_button,
            style: GoogleFonts.caveat(
              fontSize: 16,
              color: AppColors.inkMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: _save,
          child: Text(
            l10n.edit_label_save_button,
            style: GoogleFonts.caveat(
              fontSize: 16,
              color: AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
