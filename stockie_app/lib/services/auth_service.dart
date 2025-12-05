import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _usersKey = 'users';

  static const String _currentUserKey = 'currentUser';

  // Save user details
  static Future<bool> register(String email, String password, Map<String, dynamic> details) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing users
    String? usersString = prefs.getString(_usersKey);
    Map<String, dynamic> users = {};
    if (usersString != null) {
      users = jsonDecode(usersString);
    }

    // Check if user already exists
    if (users.containsKey(email)) {
      return false; // User already exists
    }

    // Save new user
    details['password'] = password; // Store password (in plain text for this demo, usually should be hashed)
    details['email'] = email; // Ensure email is in details
    users[email] = details;
    
    await prefs.setString(_usersKey, jsonEncode(users));
    
    // Set as current user
    await prefs.setString(_currentUserKey, jsonEncode(details));
    
    return true;
  }

  // Verify login credentials
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    
    String? usersString = prefs.getString(_usersKey);
    if (usersString == null) return null;

    Map<String, dynamic> users = jsonDecode(usersString);
    
    if (users.containsKey(email)) {
      final userDetails = users[email];
      if (userDetails['password'] == password) {
        // Set as current user
        await prefs.setString(_currentUserKey, jsonEncode(userDetails));
        return userDetails;
      }
    }
    
    return null;
  }

  // Get currently logged in user
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userString = prefs.getString(_currentUserKey);
    if (userString == null) return null;
    return jsonDecode(userString);
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  // Update user details
  static Future<bool> updateUser(Map<String, dynamic> updatedDetails) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get current user to identify which record to update
    String? currentUserString = prefs.getString(_currentUserKey);
    if (currentUserString == null) return false;
    
    Map<String, dynamic> currentUser = jsonDecode(currentUserString);
    String email = currentUser['email'];

    // Get all users
    String? usersString = prefs.getString(_usersKey);
    if (usersString == null) return false;
    
    Map<String, dynamic> users = jsonDecode(usersString);
    
    if (!users.containsKey(email)) return false;

    // Update specific fields in the main users map
    Map<String, dynamic> userRecord = users[email];
    if (updatedDetails.containsKey('mobile')) userRecord['mobile'] = updatedDetails['mobile'];
    if (updatedDetails.containsKey('shopName')) userRecord['shopName'] = updatedDetails['shopName'];
    if (updatedDetails.containsKey('shopAddress')) userRecord['shopAddress'] = updatedDetails['shopAddress'];
    
    users[email] = userRecord;
    
    // Save back to storage
    await prefs.setString(_usersKey, jsonEncode(users));
    
    // Update current user session
    await prefs.setString(_currentUserKey, jsonEncode(userRecord));
    
    return true;
  }
}
