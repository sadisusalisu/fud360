import 'package:fud360/models/user.dart';

enum DonationStatus { available, claimed, inProgress, completed, expired }

enum FoodType { cooked, raw, packaged, baked, fruits, other }

class Donation {
  final String id;
  final String title;
  final String description;
  final String quantity;
  final DateTime expiryTime;
  final FoodType foodType;
  final String location;
  final String address;
  final double? latitude;
  final double? longitude;
  final List<String> imageUrls;
  final String? notes;
  final String donorId;
  final String? donorName;
  final String? donorImageUrl;
  final String? receiverId;
  final String? receiverName;
  final DonationStatus status;
  final DateTime createdAt;
  final DateTime? claimedAt;
  final DateTime? completedAt;

  Donation({
    required this.id,
    required this.title,
    required this.description,
    required this.quantity,
    required this.expiryTime,
    required this.foodType,
    required this.location,
    required this.address,
    this.latitude,
    this.longitude,
    required this.imageUrls,
    this.notes,
    required this.donorId,
    this.donorName,
    this.donorImageUrl,
    this.receiverId,
    this.receiverName,
    required this.status,
    required this.createdAt,
    this.claimedAt,
    this.completedAt,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      quantity: json['quantity'],
      expiryTime: DateTime.parse(json['expiryTime']),
      foodType: FoodType.values.firstWhere(
        (e) => e.toString() == 'FoodType.${json['foodType']}',
        orElse: () => FoodType.other,
      ),
      location: json['location'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      imageUrls: List<String>.from(json['imageUrls']),
      notes: json['notes'],
      donorId: json['donorId'],
      donorName: json['donorName'],
      donorImageUrl: json['donorImageUrl'],
      receiverId: json['receiverId'],
      receiverName: json['receiverName'],
      status: DonationStatus.values.firstWhere(
        (e) => e.toString() == 'DonationStatus.${json['status']}',
        orElse: () => DonationStatus.available,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      claimedAt: json['claimedAt'] != null ? DateTime.parse(json['claimedAt']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'quantity': quantity,
      'expiryTime': expiryTime.toIso8601String(),
      'foodType': foodType.toString().split('.').last,
      'location': location,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrls': imageUrls,
      'notes': notes,
      'donorId': donorId,
      'donorName': donorName,
      'donorImageUrl': donorImageUrl,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'claimedAt': claimedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  Donation copyWith({
    String? title,
    String? description,
    String? quantity,
    DateTime? expiryTime,
    FoodType? foodType,
    String? location,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? imageUrls,
    String? notes,
    String? receiverId,
    String? receiverName,
    DonationStatus? status,
    DateTime? claimedAt,
    DateTime? completedAt,
  }) {
    return Donation(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      expiryTime: expiryTime ?? this.expiryTime,
      foodType: foodType ?? this.foodType,
      location: location ?? this.location,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrls: imageUrls ?? this.imageUrls,
      notes: notes ?? this.notes,
      donorId: this.donorId,
      donorName: this.donorName,
      donorImageUrl: this.donorImageUrl,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      status: status ?? this.status,
      createdAt: this.createdAt,
      claimedAt: claimedAt ?? this.claimedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  String get timeLeft {
    final now = DateTime.now();
    final difference = expiryTime.difference(now);
    
    if (difference.isNegative) {
      return 'Expired';
    }
    
    if (difference.inHours > 24) {
      return 'Expires in ${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return 'Expires in ${difference.inHours} hours';
    } else {
      return 'Expires in ${difference.inMinutes} minutes';
    }
  }

  bool get isExpired {
    return DateTime.now().isAfter(expiryTime);
  }

  String get foodTypeLabel {
    switch (foodType) {
      case FoodType.cooked:
        return 'Cooked Food';
      case FoodType.raw:
        return 'Raw Ingredients';
      case FoodType.packaged:
        return 'Packaged Food';
      case FoodType.baked:
        return 'Baked Goods';
      case FoodType.fruits:
        return 'Fruits & Vegetables';
      case FoodType.other:
        return 'Other';
    }
  }

  String get statusLabel {
    switch (status) {
      case DonationStatus.available:
        return 'Available';
      case DonationStatus.claimed:
        return 'Claimed';
      case DonationStatus.inProgress:
        return 'In Progress';
      case DonationStatus.completed:
        return 'Completed';
      case DonationStatus.expired:
        return 'Expired';
    }
  }
}
