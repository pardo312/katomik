import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/platform/platform_service.dart';

class AuthFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String placeholder;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final VoidCallback? onFieldSubmitted;
  final Widget? suffix;
  final bool showToggleVisibility;
  final VoidCallback? onToggleVisibility;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  
  const AuthFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.placeholder,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onFieldSubmitted,
    this.suffix,
    this.showToggleVisibility = false,
    this.onToggleVisibility,
    this.errorText,
    this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    if (context.isIOS) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoTextField(
            controller: controller,
            placeholder: placeholder,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onSubmitted: onFieldSubmitted != null ? (_) => onFieldSubmitted!() : null,
            onChanged: onChanged,
            autocorrect: false,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(8),
              border: errorText != null
                  ? Border.all(color: CupertinoColors.systemRed)
                  : null,
            ),
            suffix: showToggleVisibility && onToggleVisibility != null
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: onToggleVisibility,
                    child: Icon(
                      obscureText
                          ? CupertinoIcons.eye_slash
                          : CupertinoIcons.eye,
                      color: CupertinoColors.systemGrey,
                    ),
                  )
                : suffix,
          ),
          if (errorText != null) ...[
            const SizedBox(height: 4),
            Text(
              errorText!,
              style: const TextStyle(
                color: CupertinoColors.systemRed,
                fontSize: 12,
              ),
            ),
          ],
        ],
      );
    }
    
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: const OutlineInputBorder(),
        errorText: errorText,
        suffixIcon: showToggleVisibility && onToggleVisibility != null
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: onToggleVisibility,
              )
            : suffix,
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted != null ? (_) => onFieldSubmitted!() : null,
      onChanged: onChanged,
      autocorrect: false,
      validator: validator,
    );
  }
}