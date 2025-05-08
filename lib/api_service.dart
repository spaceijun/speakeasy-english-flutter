import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Base URL API dengan URL yang benar
  final String baseUrl = 'https://speakeasy-english.web.id/api';

  // Simpan token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Simpan user_id
  Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
    print('User ID saved: $userId'); // Log untuk debugging
  }

  // Ambil token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Ambil User ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // Cek apakah user sudah login
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    final userId = await getUserId();
    return token != null && userId != null;
  }

  // Hapus data login
  Future<void> clearLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('isLoggedIn');
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Simpan token
        if (data['token'] != null) {
          await saveToken(data['token']);
        }

        // Simpan user_id jika ada
        if (data['user'] != null && data['user']['id'] != null) {
          await saveUserId(data['user']['id']);
          print('Saved user ID: ${data['user']['id']}');
        } else {
          // Jika tidak ada user ID langsung dari response, coba ambil dari API user
          final userData = await getUser();
          if (userData != null && userData['id'] != null) {
            await saveUserId(userData['id']);
            print('Saved user ID from user API: ${userData['id']}');
          } else {
            print('Warning: Tidak bisa mendapatkan user_id');
          }
        }

        // Tandai user sudah login
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
      }

      return data;
    } catch (e) {
      print('Error saat login: $e');
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  // Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Simpan token
        if (data['token'] != null) {
          await saveToken(data['token']);
        }

        // Simpan user_id jika ada
        if (data['user'] != null && data['user']['id'] != null) {
          await saveUserId(data['user']['id']);
        } else {
          // Jika tidak ada user ID langsung dari response, coba ambil dari API user
          final userData = await getUser();
          if (userData != null && userData['id'] != null) {
            await saveUserId(userData['id']);
          }
        }

        // Tandai user sudah login
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
      }

      return data;
    } catch (e) {
      print('Error saat register: $e');
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  // Logout
  Future<bool> logout() async {
    try {
      final token = await getToken();
      if (token == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await clearLoginData();
        return true;
      }

      return false;
    } catch (e) {
      print('Error saat logout: $e');
      return false;
    }
  }

  // Get authenticated user
  Future<Map<String, dynamic>?> getUser() async {
    try {
      final token = await getToken();
      if (token == null) {
        print('Token tidak ditemukan, harap login ulang');
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);

        // Jika ini adalah pertama kali mendapatkan data user dan user_id belum disimpan
        if (userData != null && userData['id'] != null) {
          final savedUserId = await getUserId();
          if (savedUserId == null) {
            await saveUserId(userData['id']);
            print('User ID berhasil disimpan dari getUser: ${userData['id']}');
          }
        }

        return userData;
      } else if (response.statusCode == 401) {
        // Token tidak valid, hapus data login
        await clearLoginData();
        print('Token tidak valid, harap login ulang');
        return null;
      }

      print('Gagal mengambil data user: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error saat mengambil data user: $e');
      return null;
    }
  }

  // Method untuk request API yang membutuhkan autentikasi
  Future<dynamic> authenticatedRequest(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    try {
      // Cek apakah user sudah login
      final isUserLoggedIn = await isLoggedIn();
      if (!isUserLoggedIn) {
        throw Exception('User belum login, silakan login terlebih dahulu');
      }

      // Dapatkan user ID
      final userId = await getUserId();
      if (userId == null) {
        throw Exception('User ID tidak ditemukan, harap login ulang');
      }

      // Dapatkan token
      final token = await getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan, harap login ulang');
      }

      // Buat URI
      final uri = Uri.parse('$baseUrl$endpoint');

      // Buat headers dengan token
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // Eksekusi request sesuai method
      http.Response response;

      if (method == 'GET') {
        response = await http.get(uri, headers: headers);
      } else if (method == 'POST') {
        response = await http.post(
          uri,
          headers: headers,
          body: jsonEncode(body ?? {}),
        );
      } else if (method == 'PUT') {
        response = await http.put(
          uri,
          headers: headers,
          body: jsonEncode(body ?? {}),
        );
      } else if (method == 'DELETE') {
        response = await http.delete(uri, headers: headers);
      } else {
        throw Exception('Method tidak didukung');
      }

      // Parse response
      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else if (response.statusCode == 401) {
        // Token tidak valid, hapus data login
        await clearLoginData();
        throw Exception('Sesi login telah berakhir, harap login ulang');
      } else {
        throw Exception(data['message'] ?? 'Terjadi kesalahan pada server');
      }
    } catch (e) {
      throw Exception('Failed to connect to API: $e');
    }
  }
}
