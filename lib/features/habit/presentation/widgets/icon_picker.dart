import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../shared/widgets/common/habit_icon.dart';
import 'dart:io';

class IconPicker extends StatelessWidget {
  final String selectedIcon;
  final Color selectedColor;
  final ValueChanged<String> onIconSelected;

  const IconPicker({
    super.key,
    required this.selectedIcon,
    required this.selectedColor,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose an Icon',
          style: Platform.isIOS
              ? CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  )
              : Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: HabitIcon.availableIcons.length,
            itemBuilder: (context, index) {
              final iconName = HabitIcon.availableIcons[index];
              final isSelected = selectedIcon == iconName;
              
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => onIconSelected(iconName),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? selectedColor.withValues(alpha: 0.2)
                          : Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(Platform.isIOS ? 10 : 12),
                      border: Border.all(
                        color: isSelected
                            ? selectedColor
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: Center(
                      child: HabitIcon(
                        iconName: iconName,
                        size: 28,
                        color: isSelected
                            ? selectedColor
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}