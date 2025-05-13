import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fud360/models/donation.dart';
import 'package:fud360/services/api_service.dart';

class DonationProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Donation> _donations = [];
  List<Donation> _myDonations = [];
  List<Donation> _myClaimedDonations = [];
  Donation? _currentDonation;
  bool _isLoading = false;
  String? _error;

  List<Donation> get donations => _donations;
  List<Donation> get myDonations => _myDonations;
  List<Donation> get myClaimedDonations => _myClaimedDonations;
  Donation? get currentDonation => _currentDonation;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDonations({
    String? status,
    double? latitude,
    double? longitude,
    double? radius,
    String? search,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _donations = await _apiService.getDonations(
        status: status,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        search: search,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyDonations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _myDonations = await _apiService.getMyDonations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyClaimedDonations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _myClaimedDonations = await _apiService.getMyClaimedDonations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDonationById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _currentDonation = await _apiService.getDonationById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createDonation(Map<String, dynamic> donationData, List<File> images) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final donation = await _apiService.createDonation(donationData, images);
      _myDonations.add(donation);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> claimDonation(String donationId, String? notes) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final donation = await _apiService.claimDonation(donationId, notes);
      
      // Update current donation if it's the one being claimed
      if (_currentDonation != null && _currentDonation!.id == donationId) {
        _currentDonation = donation;
      }
      
      // Update in donations list
      final index = _donations.indexWhere((d) => d.id == donationId);
      if (index != -1) {
        _donations[index] = donation;
      }
      
      // Add to claimed donations
      _myClaimedDonations.add(donation);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeDonation(String donationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final donation = await _apiService.completeDonation(donationId);
      
      // Update current donation if it's the one being completed
      if (_currentDonation != null && _currentDonation!.id == donationId) {
        _currentDonation = donation;
      }
      
      // Update in my donations list
      final myIndex = _myDonations.indexWhere((d) => d.id == donationId);
      if (myIndex != -1) {
        _myDonations[myIndex] = donation;
      }
      
      // Update in claimed donations list
      final claimedIndex = _myClaimedDonations.indexWhere((d) => d.id == donationId);
      if (claimedIndex != -1) {
        _myClaimedDonations[claimedIndex] = donation;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
