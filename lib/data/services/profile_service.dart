import 'dart:io';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'graphql_client.dart';
import '../models/user.dart';

class ProfileService {
  static const String _generateAvatarUploadUrlMutation = r'''
    mutation GenerateAvatarUploadUrl($filename: String!, $contentType: String!, $fileSize: Float) {
      generateAvatarUploadUrl(filename: $filename, contentType: $contentType, fileSize: $fileSize) {
        uploadUrl
        fileUrl
        key
      }
    }
  ''';

  static const String _confirmAvatarUploadMutation = r'''
    mutation ConfirmAvatarUpload($fileUrl: String!) {
      confirmAvatarUpload(fileUrl: $fileUrl) {
        id
        email
        username
        displayName
        avatarUrl
        bio
        timezone
        isActive
        emailVerified
        createdAt
        updatedAt
      }
    }
  ''';

  static const String _syncGoogleAvatarMutation = r'''
    mutation SyncGoogleAvatar {
      syncGoogleAvatar {
        id
        email
        username
        displayName
        avatarUrl
        bio
        timezone
        isActive
        emailVerified
        createdAt
        updatedAt
      }
    }
  ''';

  static const String _updateProfileMutation = r'''
    mutation UpdateProfile($input: UpdateProfileInput!) {
      updateProfile(input: $input) {
        id
        email
        username
        displayName
        avatarUrl
        bio
        timezone
        isActive
        emailVerified
        createdAt
        updatedAt
      }
    }
  ''';

  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage({required ImageSource source}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image: ${e.toString()}');
    }
  }

  Future<User> uploadAvatar(File imageFile) async {
    try {
      final client = await GraphQLConfig.getClient();
      
      // Get file info
      final filename = imageFile.path.split('/').last;
      final bytes = await imageFile.readAsBytes();
      final contentType = _getContentType(filename);
      final fileSize = bytes.length;

      // Validate file size locally (max 5MB)
      const maxFileSize = 5 * 1024 * 1024; // 5MB in bytes
      if (fileSize > maxFileSize) {
        throw Exception('File size exceeds maximum allowed size of 5MB');
      }

      // Step 1: Generate presigned upload URL
      final generateResult = await client.mutate(
        MutationOptions(
          document: gql(_generateAvatarUploadUrlMutation),
          variables: {
            'filename': filename,
            'contentType': contentType,
            'fileSize': fileSize.toDouble(),
          },
        ),
      );

      if (generateResult.hasException) {
        throw Exception('Failed to generate upload URL: ${generateResult.exception}');
      }

      final uploadData = generateResult.data?['generateAvatarUploadUrl'];
      if (uploadData == null) {
        throw Exception('No upload URL returned');
      }

      final uploadUrl = uploadData['uploadUrl'] as String;
      final fileUrl = uploadData['fileUrl'] as String;

      // Step 2: Upload file to S3 using presigned URL
      final uploadResponse = await http.put(
        Uri.parse(uploadUrl),
        headers: {
          'Content-Type': contentType,
          'Content-Length': bytes.length.toString(),
        },
        body: bytes,
      );

      if (uploadResponse.statusCode != 200) {
        throw Exception('Failed to upload file to S3: ${uploadResponse.statusCode}');
      }

      // Step 3: Confirm upload and update user profile
      final confirmResult = await client.mutate(
        MutationOptions(
          document: gql(_confirmAvatarUploadMutation),
          variables: {
            'fileUrl': fileUrl,
          },
        ),
      );

      if (confirmResult.hasException) {
        throw Exception('Failed to confirm avatar upload: ${confirmResult.exception}');
      }

      final userData = confirmResult.data?['confirmAvatarUpload'];
      if (userData == null) {
        throw Exception('No user data returned');
      }

      return User.fromJson(userData);
    } catch (e) {
      throw Exception('Avatar upload failed: ${e.toString()}');
    }
  }

  Future<User> syncGoogleAvatar() async {
    try {
      final client = await GraphQLConfig.getClient();
      
      final result = await client.mutate(
        MutationOptions(
          document: gql(_syncGoogleAvatarMutation),
        ),
      );

      if (result.hasException) {
        throw Exception('Failed to sync Google avatar: ${result.exception}');
      }

      final userData = result.data?['syncGoogleAvatar'];
      if (userData == null) {
        throw Exception('No user data returned');
      }

      return User.fromJson(userData);
    } catch (e) {
      throw Exception('Google avatar sync failed: ${e.toString()}');
    }
  }

  Future<User> updateProfile({
    String? displayName,
    String? bio,
    String? timezone,
  }) async {
    try {
      final client = await GraphQLConfig.getClient();
      
      final variables = <String, dynamic>{};
      if (displayName != null) variables['displayName'] = displayName;
      if (bio != null) variables['bio'] = bio;
      if (timezone != null) variables['timezone'] = timezone;

      final result = await client.mutate(
        MutationOptions(
          document: gql(_updateProfileMutation),
          variables: {
            'input': variables,
          },
        ),
      );

      if (result.hasException) {
        throw Exception('Failed to update profile: ${result.exception}');
      }

      final userData = result.data?['updateProfile'];
      if (userData == null) {
        throw Exception('No user data returned');
      }

      return User.fromJson(userData);
    } catch (e) {
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }

  String _getContentType(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}