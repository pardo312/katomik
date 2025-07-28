import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:katomik/providers/theme_provider.dart';
import 'dart:io';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Theme Settings'),
        ),
        child: SafeArea(
          child: _buildContent(context, themeProvider),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
      ),
      body: _buildContent(context, themeProvider),
    );
  }
  
  Widget _buildContent(BuildContext context, ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'Theme Mode'),
          const SizedBox(height: 8),
          _buildThemeModeSelector(context, themeProvider),
          const SizedBox(height: 32),
          _buildSectionTitle(context, 'Accent Color'),
          const SizedBox(height: 16),
          _buildColorPalette(context, themeProvider),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  Widget _buildThemeModeSelector(BuildContext context, ThemeProvider themeProvider) {
    if (Platform.isIOS) {
      return CupertinoSlidingSegmentedControl<ThemeMode>(
        groupValue: themeProvider.themeMode,
        onValueChanged: (value) {
          if (value != null) {
            themeProvider.setThemeMode(value);
          }
        },
        children: const {
          ThemeMode.light: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Light'),
          ),
          ThemeMode.dark: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Dark'),
          ),
          ThemeMode.system: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('System'),
          ),
        },
      );
    }
    
    return Card(
      child: Column(
        children: [
          RadioListTile<ThemeMode>(
            title: const Text('Light'),
            value: ThemeMode.light,
            groupValue: themeProvider.themeMode,
            onChanged: (value) {
              if (value != null) {
                themeProvider.setThemeMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark'),
            value: ThemeMode.dark,
            groupValue: themeProvider.themeMode,
            onChanged: (value) {
              if (value != null) {
                themeProvider.setThemeMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('System'),
            value: ThemeMode.system,
            groupValue: themeProvider.themeMode,
            onChanged: (value) {
              if (value != null) {
                themeProvider.setThemeMode(value);
              }
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildColorPalette(BuildContext context, ThemeProvider themeProvider) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: ThemeProvider.colorPalette.length,
      itemBuilder: (context, index) {
        final color = ThemeProvider.colorPalette[index];
        final isSelected = themeProvider.selectedColorIndex == index;
        
        return GestureDetector(
          onTap: () {
            themeProvider.setColorIndex(index);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: isSelected
                ? Icon(
                    Platform.isIOS ? CupertinoIcons.check_mark : Icons.check,
                    color: Colors.white,
                    size: 24,
                  )
                : null,
          ),
        );
      },
    );
  }
}