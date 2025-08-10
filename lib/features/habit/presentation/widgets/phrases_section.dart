import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../shared/widgets/common/adaptive_widgets.dart';
import 'dart:io';

class PhrasesSection extends StatelessWidget {
  final List<TextEditingController> phraseControllers;
  final VoidCallback onAddPhrase;
  final Function(int) onRemovePhrase;
  final VoidCallback onChanged;

  const PhrasesSection({
    super.key,
    required this.phraseControllers,
    required this.onAddPhrase,
    required this.onRemovePhrase,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Why do you want to build this habit?',
              style: Platform.isIOS
                  ? CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    )
                  : Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              icon: Icon(
                Platform.isIOS ? CupertinoIcons.add : Icons.add,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: onAddPhrase,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Add phrases that motivate you',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        ...phraseControllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: AdaptiveTextField(
                    controller: controller,
                    label: 'Phrase ${index + 1}',
                    placeholder: 'Enter a motivating phrase',
                    prefix: Icon(
                      Platform.isIOS
                          ? CupertinoIcons.quote_bubble
                          : Icons.format_quote,
                      size: 20,
                    ),
                    onChanged: (_) => onChanged(),
                  ),
                ),
                if (phraseControllers.length > 1)
                  IconButton(
                    icon: Icon(
                      Platform.isIOS
                          ? CupertinoIcons.minus_circle
                          : Icons.remove_circle_outline,
                      color: Colors.red,
                    ),
                    onPressed: () => onRemovePhrase(index),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
