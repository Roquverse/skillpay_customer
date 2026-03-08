import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

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

  /// 3. Call the custom RPC to create or update the public.user_profiles record.
  /// Bypasses RLS to insert their location and final details.
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

      await _supabase.rpc(
        'create_or_update_user_profile',
        params: {
          'p_user_id': user.id,
          'p_email': email,
          'p_full_name': fullName,
          'p_phone_number': phone,
          'p_home_address': address,
          'p_profile_image_url': null,
          'p_user_type': userType.toLowerCase(), // e.g. 'customer'
        },
      );
    } catch (e) {
      throw Exception(_formatError(e));
    }
  }

  /// 4. Upload a profile image to Supabase Storage and update the profile URL.
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User is not authenticated.');
      }

      final fileExt = imageFile.path.split('.').last;
      final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = fileName; // Upload directly to root of bucket

      // Assuming a bucket named 'avatars' exists and is publicly readable
      await _supabase.storage.from('avatars').upload(
        filePath,
        imageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(filePath);

      // Update auth metadata
      await _supabase.auth.updateUser(
        UserAttributes(data: {'profile_image_url': imageUrl}),
      );

      // Update user_profiles table
      await _supabase.from('user_profiles').update({
        'profile_image_url': imageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);

      return imageUrl;
    } catch (e) {
      throw Exception(_formatError(e));
    }
  }

  /// 4. Update the user profile details
  Future<void> updateUserProfile({
    required String fullName,
    required String phone,
    required String dateOfBirth, // Optional for future use
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User is not authenticated.');
      }

      // 1. Update auth.users metadata first (for quick fallback access)
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': fullName,
            'phone': phone,
            'dob': dateOfBirth,
          },
        ),
      );

      // 2. Try to update the public.user_profiles table.
      final existingProfile = await _supabase
          .from('user_profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (existingProfile != null) {
        // Just update existing fields without touching others like home_address or user_type
        await _supabase.from('user_profiles').update({
          'full_name': fullName,
          'phone_number': phone,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', user.id);
      } else {
        // Insert the missing row with the required user_type column
        final defaultRole = user.userMetadata?['role']?.toString().toLowerCase() ?? 'customer';
        await _supabase.from('user_profiles').insert({
          'id': user.id,
          'full_name': fullName,
          'phone_number': phone,
          'email': user.email,
          'user_type': defaultRole,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
      
    } catch (e) {
      throw Exception(_formatError(e));
    }
  }

  /// 5. Sign in an existing user
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception(_formatError(e));
    }
  }

  /// 5. Sign out the current user
  Future<void> signOut() async {
    try {
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
