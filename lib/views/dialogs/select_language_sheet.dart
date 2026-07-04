import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class LanguageOption {
  final String code;
  final String label;
  final String nativeLabel;
  final String flag;

  const LanguageOption({
    required this.code,
    required this.label,
    required this.nativeLabel,
    this.flag = '',
  });
}

const List<LanguageOption> kAvailableLanguages = [
  LanguageOption(code: 'auto', label: 'Device Default', nativeLabel: 'Device Default'),
  LanguageOption(code: 'en', label: 'English', nativeLabel: 'English', flag: '🇺🇸'),
  LanguageOption(code: 'ru', label: 'Русский', nativeLabel: 'Russian', flag: '🇷🇺'),
  LanguageOption(code: 'es', label: 'Español', nativeLabel: 'Spanish', flag: '🇪🇸'),
  LanguageOption(code: 'fr', label: 'Français', nativeLabel: 'French', flag: '🇫🇷'),
];

class SelectLanguageSheet extends StatelessWidget {
  final String currentLocaleCode;
  final ValueChanged<String> onSelected;

  const SelectLanguageSheet({
    super.key,
    required this.currentLocaleCode,
    required this.onSelected,
  });

  static Future<String?> show(
    BuildContext context, {
    required String currentLocaleCode,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SelectLanguageSheet(
        currentLocaleCode: currentLocaleCode,
        onSelected: (code) => Navigator.of(ctx).pop(code),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.paperLight,
        border: Border(
          top: BorderSide(color: AppColors.ink, width: 2),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Text(
                'Language',
                style: GoogleFonts.architectsDaughter(
                  fontSize: 18,
                  color: AppColors.ink,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const Divider(
              color: AppColors.inkHairline,
              height: 1.5,
              thickness: 1.5,
            ),
            ListView.separated(
              shrinkWrap: true,
              itemCount: kAvailableLanguages.length,
              separatorBuilder: (_, _) => const Divider(
                color: AppColors.inkHairline,
                height: 1,
                thickness: 1,
              ),
              itemBuilder: (context, index) {
                final lang = kAvailableLanguages[index];
                final isSelected = lang.code == currentLocaleCode;

                return GestureDetector(
                  onTap: () => onSelected(lang.code),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    color: isSelected
                        ? AppColors.terracotta.withValues(alpha: 0.1)
                        : Colors.transparent,
                    child: Row(
                      children: [
                        if (lang.flag.isNotEmpty) ...[
                          Text(
                            lang.flag,
                            style: const TextStyle(fontSize: 26),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang.label,
                                style: GoogleFonts.patrickHand(
                                  fontSize: 15,
                                  color: AppColors.ink,
                                ),
                              ),
                              if (lang.nativeLabel != lang.label)
                                Text(
                                  lang.nativeLabel,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 11,
                                    color: AppColors.inkMuted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.terracotta,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.ink, width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                '✓',
                                style: GoogleFonts.caveat(
                                  fontSize: 14,
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: Text(
                'App will restart to apply language change',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: AppColors.inkMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
