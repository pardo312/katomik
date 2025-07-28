import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

class AdaptiveScaffold extends StatelessWidget {
  final Widget? title;
  final Widget body;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  
  const AdaptiveScaffold({
    super.key,
    this.title,
    required this.body,
    this.leading,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
  });
  
  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: title != null
            ? CupertinoNavigationBar(
                middle: title,
                leading: leading,
                trailing: actions?.isNotEmpty == true
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: actions!,
                      )
                    : null,
                backgroundColor: backgroundColor?.withValues(alpha: 0.9) ?? 
                    CupertinoTheme.of(context).barBackgroundColor.withValues(alpha: 0.9),
                border: null,
              )
            : null,
        backgroundColor: backgroundColor ?? CupertinoColors.systemGroupedBackground,
        child: SafeArea(
          child: Stack(
            children: [
              body,
              if (floatingActionButton != null)
                Positioned(
                  right: 16,
                  bottom: bottomNavigationBar != null ? 88 : 16,
                  child: floatingActionButton!,
                ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: title != null
          ? AppBar(
              title: title,
              leading: leading,
              actions: actions,
              backgroundColor: backgroundColor,
            )
          : null,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      backgroundColor: backgroundColor,
    );
  }
}

class AdaptiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final bool isPrimary;
  final IconData? icon;
  final EdgeInsets? padding;
  
  const AdaptiveButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isDestructive = false,
    this.isPrimary = true,
    this.icon,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? CupertinoColors.destructiveRed
        : isPrimary
            ? Theme.of(context).colorScheme.primary
            : null;
    
    if (Platform.isIOS) {
      if (isPrimary) {
        return CupertinoButton.filled(
          onPressed: onPressed,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(text),
            ],
          ),
        );
      }
      
      return CupertinoButton(
        onPressed: onPressed,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(color: color),
            ),
          ],
        ),
      );
    }
    
    if (isPrimary) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDestructive ? Theme.of(context).colorScheme.error : null,
          foregroundColor: isDestructive ? Theme.of(context).colorScheme.onError : null,
          padding: padding,
        ),
      );
    }
    
    return TextButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
      label: Text(text),
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: padding,
      ),
    );
  }
}

class AdaptiveTextField extends StatelessWidget {
  final String? label;
  final String? placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final Widget? prefix;
  final Widget? suffix;
  
  const AdaptiveTextField({
    super.key,
    this.label,
    this.placeholder,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.prefix,
    this.suffix,
  });
  
  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                fontSize: 13,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
            const SizedBox(height: 8),
          ],
          CupertinoTextField(
            controller: controller,
            onChanged: onChanged,
            placeholder: placeholder,
            keyboardType: keyboardType,
            obscureText: obscureText,
            maxLines: maxLines,
            prefix: prefix != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: prefix,
                  )
                : null,
            suffix: suffix != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: suffix,
                  )
                : null,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: CupertinoColors.tertiarySystemFill,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      );
    }
    
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: placeholder,
        prefixIcon: prefix,
        suffixIcon: suffix,
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
    );
  }
}

class AdaptiveSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  
  const AdaptiveSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });
  
  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        // ignore: deprecated_member_use
        activeColor: activeColor ?? CupertinoColors.systemGreen,
      );
    }
    
    return Switch(
      value: value,
      onChanged: onChanged,
      activeTrackColor: activeColor,
    );
  }
}

class AdaptiveDialog extends StatelessWidget {
  final String? title;
  final Widget? content;
  final List<Widget> actions;
  
  const AdaptiveDialog({
    super.key,
    this.title,
    this.content,
    required this.actions,
  });
  
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    Widget? content,
    required List<AdaptiveDialogAction> actions,
  }) {
    if (Platform.isIOS) {
      return showCupertinoDialog<T>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: content,
          actions: actions.map((action) => CupertinoDialogAction(
            onPressed: action.onPressed,
            isDefaultAction: action.isPrimary,
            isDestructiveAction: action.isDestructive,
            child: Text(action.text),
          )).toList(),
        ),
      );
    }
    
    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: content,
        actions: actions.map((action) => TextButton(
          onPressed: action.onPressed,
          child: Text(
            action.text,
            style: TextStyle(
              color: action.isDestructive
                  ? Theme.of(context).colorScheme.error
                  : action.isPrimary
                      ? Theme.of(context).colorScheme.primary
                      : null,
              fontWeight: action.isPrimary ? FontWeight.bold : null,
            ),
          ),
        )).toList(),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoAlertDialog(
        title: title != null ? Text(title!) : null,
        content: content,
        actions: actions,
      );
    }
    
    return AlertDialog(
      title: title != null ? Text(title!) : null,
      content: content,
      actions: actions,
    );
  }
}

class AdaptiveDialogAction {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isDestructive;
  
  const AdaptiveDialogAction({
    required this.text,
    this.onPressed,
    this.isPrimary = false,
    this.isDestructive = false,
  });
}

class AdaptiveProgressIndicator extends StatelessWidget {
  final double? size;
  final Color? color;
  
  const AdaptiveProgressIndicator({
    super.key,
    this.size,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoActivityIndicator(
        radius: (size ?? 20) / 2,
        color: color,
      );
    }
    
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: color != null ? AlwaysStoppedAnimation<Color>(color!) : null,
      ),
    );
  }
}

class AdaptiveDatePicker extends StatelessWidget {
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime> onDateSelected;
  
  const AdaptiveDatePicker({
    super.key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    required this.onDateSelected,
  });
  
  static Future<void> show({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    required ValueChanged<DateTime> onDateSelected,
  }) async {
    final now = DateTime.now();
    final initial = initialDate ?? now;
    final first = firstDate ?? DateTime(now.year - 10);
    final last = lastDate ?? DateTime(now.year + 10);
    
    if (Platform.isIOS) {
      await showCupertinoModalPopup(
        context: context,
        builder: (context) => Container(
          height: 300,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Done',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initial,
                  minimumDate: first,
                  maximumDate: last,
                  onDateTimeChanged: onDateSelected,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      final date = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: first,
        lastDate: last,
      );
      
      if (date != null) {
        onDateSelected(date);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}