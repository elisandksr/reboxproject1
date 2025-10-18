// File: user_data.dart
// Simpan file ini di folder lib/ bersama login_screen.dart dan signup_screen.dart

class UserData {
  // Static list untuk menyimpan semua user yang terdaftar
  static final List<Map<String, String>> _registeredUsers = [];

  // Method untuk menambah user baru
  static void addUser(String username, String mobile, String password) {
    // Trim whitespace dan simpan
    final cleanUsername = username.trim();
    final cleanPassword = password.trim();
    
    _registeredUsers.add({
      'username': cleanUsername,
      'mobile': mobile.trim(),
      'password': cleanPassword,
    });
    
    // Debug: Print untuk memastikan data tersimpan
    print('✅ User registered: $cleanUsername');
    print('📊 Total users: ${_registeredUsers.length}');
    print('🔍 All users: $_registeredUsers');
  }

  // Method untuk validasi login
  static bool validateUser(String username, String password) {
    // Trim whitespace sebelum validasi
    final cleanUsername = username.trim();
    final cleanPassword = password.trim();
    
    // Debug: Print untuk cek validasi
    print('🔐 Attempting login...');
    print('   Username: "$cleanUsername"');
    print('   Password: "$cleanPassword"');
    print('   Available users: $_registeredUsers');
    
    bool found = _registeredUsers.any(
      (user) {
        bool usernameMatch = user['username'] == cleanUsername;
        bool passwordMatch = user['password'] == cleanPassword;
        
        print('   Checking: ${user['username']} - Username match: $usernameMatch, Password match: $passwordMatch');
        
        return usernameMatch && passwordMatch;
      },
    );
    
    print('   Result: ${found ? "✅ SUCCESS" : "❌ FAILED"}');
    
    return found;
  }

  // Method untuk mendapatkan semua user (untuk debugging)
  static List<Map<String, String>> getAllUsers() {
    return _registeredUsers;
  }

  // Method untuk cek apakah username sudah terdaftar
  static bool isUsernameExist(String username) {
    final cleanUsername = username.trim();
    return _registeredUsers.any((user) => user['username'] == cleanUsername);
  }

  // Method untuk clear semua data (untuk testing)
  static void clearAllUsers() {
    _registeredUsers.clear();
    print('🗑️ All users cleared');
  }
  
  // Method untuk melihat jumlah user terdaftar
  static int getUserCount() {
    return _registeredUsers.length;
  }
}