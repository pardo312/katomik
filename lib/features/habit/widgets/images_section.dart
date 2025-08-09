import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

class ImagesSection extends StatelessWidget {
  final List<String> imagePaths;
  final VoidCallback onAddImage;
  final Function(int) onRemoveImage;

  const ImagesSection({
    super.key,
    required this.imagePaths,
    required this.onAddImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 8),
        _buildSubtitle(context),
        const SizedBox(height: 12),
        _buildImageList(context),
      ],
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    return Text(
      'Add Images',
      style: Platform.isIOS
          ? CupertinoTheme.of(context).textTheme.textStyle.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            )
          : Theme.of(context).textTheme.titleMedium,
    );
  }
  
  Widget _buildSubtitle(BuildContext context) {
    return Text(
      'Add images that inspire you',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
  
  Widget _buildImageList(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ..._buildImageItems(context),
          _buildAddImageButton(context),
        ],
      ),
    );
  }
  
  List<Widget> _buildImageItems(BuildContext context) {
    return imagePaths.asMap().entries.map((entry) {
      final index = entry.key;
      final imagePath = entry.value;
      return _buildImageItem(context, index, imagePath);
    }).toList();
  }
  
  Widget _buildImageItem(BuildContext context, int index, String imagePath) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          _buildImageContainer(context, imagePath),
          _buildRemoveButton(index),
        ],
      ),
    );
  }
  
  Widget _buildImageContainer(BuildContext context, String imagePath) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Platform.isIOS ? 10 : 12),
        image: DecorationImage(
          image: FileImage(File(imagePath)),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
  
  Widget _buildRemoveButton(int index) {
    return Positioned(
      top: 4,
      right: 4,
      child: GestureDetector(
        onTap: () => onRemoveImage(index),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
  
  Widget _buildAddImageButton(BuildContext context) {
    return GestureDetector(
      onTap: onAddImage,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(Platform.isIOS ? 10 : 12),
          border: Border.all(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Icon(
            Platform.isIOS ? CupertinoIcons.camera : Icons.camera_alt,
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}