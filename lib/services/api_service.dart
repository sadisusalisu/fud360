import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:fud360/models/user.dart';
import 'package:fud360/models/donation.dart';
import 'package:fud360/models/notification.dart';

class ApiService {
  static const String baseUrl = 'https://api.fud360.org/v1'; // Example API URL
  String? _token;

  // Set auth token
  void setToken(String token) {
    _token = token;
  }

  // Clear auth token
  void clearToken() {
    _token = null;
  }

  // Headers with auth token
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }

  // Handle API response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'An error occurred');
    }
  }

  // Authentication APIs
  Future<Map<String, dynamic>> register(String name, String email, String phone, String password, UserRole role, String? organization) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role.toString().split('.').last,
        'organization': organization,
      }),
    );
    
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> loginWithPhone(String phone, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/phone'),
      headers: _headers,
      body: jsonEncode({
        'phone': phone,
        'otp': otp,
      }),
    );
    
    return _handleResponse(response);
  }

  Future<void> requestOtp(String phone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/otp/request'),
      headers: _headers,
      body: jsonEncode({
        'phone': phone,
      }),
    );
    
    _handleResponse(response);
  }

  Future<User> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: _headers,
    );
    
    final data = _handleResponse(response);
    return User.fromJson(data);
  }

  // Donation APIs
  Future<List<Donation>> getDonations({
    String? status,
    double? latitude,
    double? longitude,
    double? radius,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    
    if (status != null) queryParams['status'] = status;
    if (latitude != null) queryParams['latitude'] = latitude.toString();
    if (longitude != null) queryParams['longitude'] = longitude.toString();
    if (radius != null) queryParams['radius'] = radius.toString();
    if (search != null) queryParams['search'] = search;
    
    final uri = Uri.parse('$baseUrl/donations').replace(queryParameters: queryParams);
    
    final response = await http.get(
      uri,
      headers: _headers,
    );
    
    final data = _handleResponse(response);
    return (data as List).map((item) => Donation.fromJson(item)).toList();
  }

  Future<List<Donation>> getMyDonations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/donations/my'),
      headers: _headers,
    );
    
    final data = _handleResponse(response);
    return (data as List).map((item) => Donation.fromJson(item)).toList();
  }

  Future<List<Donation>> getMyClaimedDonations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/donations/claimed'),
      headers: _headers,
    );
    
    final data = _handleResponse(response);
    return (data as List).map((item) => Donation.fromJson(item)).toList();
  }

  Future<Donation> getDonationById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/donations/$id'),
      headers: _headers,
    );
    
    final data = _handleResponse(response);
    return Donation.fromJson(data);
  }

  Future<Donation> createDonation(Map<String, dynamic> donationData, List<File> images) async {
    // First upload images
    final imageUrls = await _uploadImages(images);
    
    // Add image URLs to donation data
    donationData['imageUrls'] = imageUrls;
    
    final response = await http.post(
      Uri.parse('$baseUrl/donations'),
      headers: _headers,
      body: jsonEncode(donationData),
    );
    
    final data = _handleResponse(response);
    return Donation.fromJson(data);
  }

  Future<Donation> claimDonation(String donationId, String? notes) async {
    final response = await http.post(
      Uri.parse('$baseUrl/donations/$donationId/claim'),
      headers: _headers,
      body: jsonEncode({
        'notes': notes,
      }),
    );
    
    final data = _handleResponse(response);
    return Donation.fromJson(data);
  }

  Future<Donation> completeDonation(String donationId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/donations/$donationId/complete'),
      headers: _headers,
    );
    
    final data = _handleResponse(response);
    return Donation.fromJson(data);
  }

  // Notification APIs
  Future<List<AppNotification>> getNotifications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications'),
      headers: _headers,
    );
    
    final data = _handleResponse(response);
    return (data as List).map((item) => AppNotification.fromJson(item)).toList();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notifications/$notificationId/read'),
      headers: _headers,
    );
    
    _handleResponse(response);
  }

  Future<void> markAllNotificationsAsRead() async {
    final response = await http.post(
      Uri.parse('$baseUrl/notifications/read-all'),
      headers: _headers,
    );
    
    _handleResponse(response);
  }

  // Profile APIs
  Future<User> updateProfile(Map<String, dynamic> profileData, File? profileImage) async {
    if (profileImage != null) {
      final imageUrls = await _uploadImages([profileImage]);
      if (imageUrls.isNotEmpty) {
        profileData['profileImageUrl'] = imageUrls.first;
      }
    }
    
    final response = await http.put(
      Uri.parse('$baseUrl/users/me'),
      headers: _headers,
      body: jsonEncode(profileData),
    );
    
    final data = _handleResponse(response);
    return User.fromJson(data);
  }

  // Helper method to upload images
  Future<List<String>> _uploadImages(List<File> images) async {
    final urls = <String>[];
    
    for (final image in images) {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/uploads/images'),
      );
      
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
        ),
      );
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      final data = _handleResponse(response);
      urls.add(data['url']);
    }
    
    return urls;
  }

  // Admin APIs (for admin users only)
  Future<List<User>> getAllUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/users'),
      headers: _headers,
    );
    
    final data = _handleResponse(response);
    return (data as List).map((item) => User.fromJson(item)).toList();
  }

  Future<List<Donation>> getAllDonations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/donations'),
      headers: _headers,
    );
    
    final data = _handleResponse(response);
    return (data as List).map((item) => Donation.fromJson(item)).toList();
  }

  Future<Map<String, dynamic>> getStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/stats'),
      headers: _headers,
    );
    
    return _handleResponse(response);
  }
}
