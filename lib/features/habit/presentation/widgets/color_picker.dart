import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import '../../../../l10n/app_localizations.dart';

class ColorPicker extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;
  final List<Color> availableColors;

  const ColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
    this.availableColors = const [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
      Colors.brown,
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).chooseColor,
          style: Platform.isIOS
              ? CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  )
              : Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: availableColors.map((color) {
            final isSelected = selectedColor == color;
            return GestureDetector(
              onTap: () => onColorSelected(color),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(Platform.isIOS ? 10 : 12),
                  border: isSelected
                      ? Border.all(
                          color: Platform.isIOS
                              ? CupertinoColors.activeBlue
                              : Theme.of(context).colorScheme.primary,
                          width: 3,
                        )
                      : null,
                ),
                child: isSelected
                    ? Icon(
                        Platform.isIOS ? CupertinoIcons.checkmark : Icons.check,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}