import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'api_client.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ApiClient _api = ApiClient.instance;

  /// 1. Sign up the user with email/password.
  /// Generates the 6-digit OTP sent to their email.
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
  }) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
          'role': role,
        },
      );
    } catch (e) {
      throw Exception(_formatError(e));
    }
  }

  /// 2. Verify the 6-digit OTP sent to the user's email.
  Future<void> verifyEmailOTP(String email, String otp) async {
    try {
      await _supabase.auth.verifyOTP(
        type: OtpType.signup,
        email: email,
        token: otp,
      );
    } catch (e) {
      throw Exception(_formatError(e));
    }
  }

  /// 3. Initial profile setup via backend API
  Future<void> finishProfileSetup({
    required String email,
    required String fullName,
    required String phone,
    required String address,
    required String userType,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User is not authenticated.');
      }

      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': fullName,
            'phone': phone,
            'address': address,
          },
        ),
      );

      try {
        await _api.post(
          '/homeowners/profile/setup',
          body: {
            'fullName': fullName,
            'phone': phone,
            'defaultAddress': address,
          },
        );
      } catch (e) {
        debugPrint('[AuthService] Backend profile setup notice: $e');
      }
    } catch (e) {
      throw Exception(_formatError(e));
    }
  }

  /// 4. Fetch the homeowner user profile
  Future<Map<String, dynamic>> fetchUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return {'full_name': 'User', 'email': '', 'phone_number': ''};
    }

    try {
      final data = await _api.get('/homeowners/profile');
      if (data is Map<String, dynamic>) {
        return {
          'id': data['userId'] ?? data['id'] ?? user.id,
          'full_name': data['fullName'] ??
              user.userMetadata?['full_name'] ??
              'User',
          'email': data['user']?['email'] ?? user.email ?? '',
          'phone_number': data['user']?['phone'] ??
              data['phone'] ??
              user.userMetadata?['phone'] ??
              '',
          'profile_image_url': data['profilePhoto'] ??
              user.userMetadata?['avatar_url'] ??
              user.userMetadata?['profile_image_url'],
          'address': data['defaultAddress'],
          'date_of_birth': data['dateOfBirth'],
        };
      }
    } catch (e) {
      debugPrint('[AuthService] Backend profile fetch notice: $e');
    }

    return {
      'id': user.id,
      'full_name': user.userMetadata?['full_name'] ?? 'User',
      'email': user.email ?? '',
      'phone_number': user.userMetadata?['phone'] ?? '',
      'profile_image_url': user.userMetadata?['avatar_url'] ??
          user.userMetadata?['profile_image_url'],
    };
  }

  /// 5. Upload a profile image to Supabase Storage and update the profile URL.
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User is not authenticated.');
      }

      final fileExt = imageFile.path.split('.').last;
      final fileName =
          '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = fileName;

      await _supabase.storage.from('avatars').upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final imageUrl =
          _supabase.storage.from('avatars').getPublicUrl(filePath);

      await _supabase.auth.updateUser(
        UserAttributes(data: {'profile_image_url': imageUrl}),
      );

      try {
        await _api.patch(
          '/homeowners/profile',
          body: {'profilePhoto': imageUrl},
        );
      } catch (e) {
        debugPrint('[AuthService] Backend photo patch notice: $e');
      }

      return imageUrl;
    } catch (e) {
      throw Exception(_formatError(e));
    }
  }

  /// 6. Update the user profile details
  Future<void> updateUserProfile({
    required String fullName,
    required String phone,
    required String dateOfBirth,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User is not authenticated.');
      }

      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': fullName,
            'phone': phone,
            'dob': dateOfBirth,
          },
        ),
      );

      try {
        await _api.patch(
          '/homeowners/profile',
          body: {
            'fullName': fullName,
            'phone': phone,
            if (dateOfBirth.isNotEmpty) 'dateOfBirth': dateOfBirth,
          },
        );
      } catch (e) {
        debugPrint('[AuthService] Backend profile patch notice: $e');
      }
    } catch (e) {
      throw Exception(_formatError(e));
    }
  }

  /// 7. Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final isDeactivated =
          response.user?.userMetadata?['is_deactivated'] == true;
      if (isDeactivated) {
        await _supabase.auth.signOut();
        throw const AuthException(
          'Your account has been deactivated. Please contact support to reactivate your account.',
        );
      }
    } catch (e) {
      throw Exception(_formatError(e));
    }
  }

  /// 8. Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception(_formatError(e));
    }
  }

  /// 9. Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception(_formatError(e));
    }
  }

  /// 10. Deactivate account
  Future<void> deactivateAccount() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      try {
        await _api.post('/auth/deactivate');
      } catch (_) {}

      try {
        await _supabase.auth.updateUser(
          UserAttributes(
            data: {
              'is_deactivated': true,
              'deactivated_at': DateTime.now().toIso8601String(),
            },
          ),
        );
      } catch (_) {}

      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception(_formatError(e));
    }
  }

  /// Helper to extract clean error messages from Supabase exceptions
  String _formatError(dynamic e) {
    if (e is AuthException) {
      return e.message;
    } else if (e is PostgrestException) {
      return e.message;
    }
    return e.toString();
  }
}
