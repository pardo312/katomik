import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import '../../../core/platform/platform_service.dart';
import '../../../core/platform/platform_constants.dart';

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
                    ? Row(mainAxisSize: MainAxisSize.min, children: actions!)
                    : null,
                backgroundColor:
                    backgroundColor?.withValues(alpha: 0.9) ??
                    CupertinoTheme.of(
                      context,
                    ).barBackgroundColor.withValues(alpha: 0.9),
                border: null,
              )
            : null,
        backgroundColor:
            backgroundColor ?? CupertinoColors.systemGroupedBackground,
        child: SafeArea(
          child: Stack(
            children: [
              body,
              if (floatingActionButton != null)
                Positioned(right: 16, bottom: 16, child: floatingActionButton!),
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
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
            ],
            Text(text, style: TextStyle(color: color)),
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
          backgroundColor: isDestructive
              ? Theme.of(context).colorScheme.error
              : null,
          foregroundColor: isDestructive
              ? Theme.of(context).colorScheme.onError
              : null,
          padding: padding,
        ),
      );
    }

    return TextButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
      label: Text(text),
      style: TextButton.styleFrom(foregroundColor: color, padding: padding),
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
          actions: actions
              .map(
                (action) => CupertinoDialogAction(
                  onPressed: action.onPressed,
                  isDefaultAction: action.isPrimary,
                  isDestructiveAction: action.isDestructive,
                  child: Text(action.text),
                ),
              )
              .toList(),
        ),
      );
    }

    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: content,
        actions: actions
            .map(
              (action) => TextButton(
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
              ),
            )
            .toList(),
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

  const AdaptiveProgressIndicator({super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoActivityIndicator(radius: (size ?? 20) / 2, color: color);
    }

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: color != null
            ? AlwaysStoppedAnimation<Color>(color!)
            : null,
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

class AdaptiveIcon extends StatelessWidget {
  final IconData? materialIcon;
  final IconData? cupertinoIcon;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  const AdaptiveIcon({
    super.key,
    this.materialIcon,
    this.cupertinoIcon,
    this.size,
    this.color,
    this.semanticLabel,
  }) : assert(
         materialIcon != null || cupertinoIcon != null,
         'At least one icon must be provided',
       );

  @override
  Widget build(BuildContext context) {
    final platform = DefaultPlatformService();
    final iconData = platform.isCupertino
        ? (cupertinoIcon ?? materialIcon!)
        : (materialIcon ?? cupertinoIcon!);

    return Icon(
      iconData,
      size: size ?? PlatformConstants.mediumIconSize,
      color: color,
      semanticLabel: semanticLabel,
    );
  }

  // Factory constructors for common icons
  factory AdaptiveIcon.home({bool active = false, double? size, Color? color}) {
    return AdaptiveIcon(
      materialIcon: active ? Icons.home : Icons.home_outlined,
      cupertinoIcon: active ? CupertinoIcons.house_fill : CupertinoIcons.house,
      size: size,
      color: color,
    );
  }

  factory AdaptiveIcon.add({double? size, Color? color}) {
    return AdaptiveIcon(
      materialIcon: Icons.add,
      cupertinoIcon: CupertinoIcons.add,
      size: size,
      color: color,
    );
  }

  factory AdaptiveIcon.edit({double? size, Color? color}) {
    return AdaptiveIcon(
      materialIcon: Icons.edit,
      cupertinoIcon: CupertinoIcons.pencil,
      size: size,
      color: color,
    );
  }

  factory AdaptiveIcon.delete({double? size, Color? color}) {
    return AdaptiveIcon(
      materialIcon: Icons.delete,
      cupertinoIcon: CupertinoIcons.delete,
      size: size,
      color: color,
    );
  }

  factory AdaptiveIcon.check({double? size, Color? color}) {
    return AdaptiveIcon(
      materialIcon: Icons.check,
      cupertinoIcon: CupertinoIcons.checkmark,
      size: size,
      color: color,
    );
  }

  factory AdaptiveIcon.settings({double? size, Color? color}) {
    return AdaptiveIcon(
      materialIcon: Icons.settings,
      cupertinoIcon: CupertinoIcons.settings,
      size: size,
      color: color,
    );
  }

  factory AdaptiveIcon.search({double? size, Color? color}) {
    return AdaptiveIcon(
      materialIcon: Icons.search,
      cupertinoIcon: CupertinoIcons.search,
      size: size,
      color: color,
    );
  }

  factory AdaptiveIcon.back({double? size, Color? color}) {
    return AdaptiveIcon(
      materialIcon: Icons.arrow_back,
      cupertinoIcon: CupertinoIcons.back,
      size: size,
      color: color,
    );
  }

  factory AdaptiveIcon.forward({double? size, Color? color}) {
    return AdaptiveIcon(
      materialIcon: Icons.arrow_forward,
      cupertinoIcon: CupertinoIcons.forward,
      size: size,
      color: color,
    );
  }

  factory AdaptiveIcon.share({double? size, Color? color}) {
    return AdaptiveIcon(
      materialIcon: Icons.share,
      cupertinoIcon: CupertinoIcons.share,
      size: size,
      color: color,
    );
  }
}

class AdaptiveListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsets? contentPadding;
  final bool enabled;
  final bool selected;
  final Color? selectedColor;
  final Color? backgroundColor;

  const AdaptiveListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.contentPadding,
    this.enabled = true,
    this.selected = false,
    this.selectedColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final platform = DefaultPlatformService();

    if (platform.isCupertino) {
      final content = Container(
        padding: contentPadding ?? PlatformConstants.defaultButtonPadding,
        decoration: BoxDecoration(
          color: selected
              ? (selectedColor ??
                        CupertinoColors.systemGrey4.resolveFrom(context))
                    .withValues(alpha: 0.3)
              : backgroundColor ?? Colors.transparent,
          borderRadius: PlatformConstants.smallBorderRadius,
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              SizedBox(width: PlatformConstants.mediumSpace),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null)
                    DefaultTextStyle(
                      style: CupertinoTheme.of(context).textTheme.textStyle
                          .copyWith(
                            fontSize: 17,
                            color: enabled ? null : CupertinoColors.systemGrey,
                          ),
                      child: title!,
                    ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    DefaultTextStyle(
                      style: CupertinoTheme.of(context).textTheme.textStyle
                          .copyWith(
                            fontSize: 15,
                            color: CupertinoColors.secondaryLabel.resolveFrom(
                              context,
                            ),
                          ),
                      child: subtitle!,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              SizedBox(width: PlatformConstants.mediumSpace),
              trailing!,
            ],
          ],
        ),
      );

      return GestureDetector(
        onTap: enabled ? onTap : null,
        onLongPress: enabled ? onLongPress : null,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    // Material Design
    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
      onLongPress: onLongPress,
      contentPadding: contentPadding,
      enabled: enabled,
      selected: selected,
      selectedColor: selectedColor,
      tileColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: PlatformConstants.smallBorderRadius,
      ),
    );
  }
}

class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool automaticallyImplyLeading;
  final double? elevation;
  final PreferredSizeWidget? bottom;

  const AdaptiveAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.automaticallyImplyLeading = true,
    this.elevation,
    this.bottom,
  });

  @override
  Size get preferredSize => Size.fromHeight(
    (DefaultPlatformService().isCupertino ? 44.0 : kToolbarHeight) +
        (bottom?.preferredSize.height ?? 0.0),
  );

  @override
  Widget build(BuildContext context) {
    final platform = DefaultPlatformService();

    if (platform.isCupertino) {
      return CupertinoNavigationBar(
        middle: title,
        leading: leading,
        trailing: actions?.isNotEmpty == true
            ? Row(mainAxisSize: MainAxisSize.min, children: actions!)
            : null,
        backgroundColor:
            backgroundColor?.withValues(alpha: 0.9) ??
            CupertinoTheme.of(
              context,
            ).barBackgroundColor.withValues(alpha: 0.9),
        border: elevation == 0
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0x4C000000), width: 0.0),
              ),
        automaticallyImplyLeading: automaticallyImplyLeading,
      );
    }

    return AppBar(
      title: title,
      leading: leading,
      actions: actions,
      backgroundColor: backgroundColor,
      automaticallyImplyLeading: automaticallyImplyLeading,
      elevation: elevation,
      centerTitle: PlatformConstants.centerTitle,
      bottom: bottom,
    );
  }
}
