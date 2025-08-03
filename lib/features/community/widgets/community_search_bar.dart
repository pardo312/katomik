import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

class CommunitySearchBar extends StatelessWidget {
  final Function(String) onChanged;
  final String? hintText;

  const CommunitySearchBar({super.key, required this.onChanged, this.hintText});

  @override
  Widget build(BuildContext context) {
    final placeholder = hintText ?? 'Search communities...';
    
    if (Platform.isIOS) {
      return CupertinoTextField(
        onChanged: onChanged,
        placeholder: placeholder,
        placeholderStyle: TextStyle(color: CupertinoColors.systemGrey2, fontSize: 16),
        prefix: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Icon(
            CupertinoIcons.search,
            color: CupertinoColors.systemGrey,
            size: 20,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: CupertinoColors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        style: const TextStyle(fontSize: 16, color: Colors.white),
      );
    } else {
      return Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      );
    }
  }
}
