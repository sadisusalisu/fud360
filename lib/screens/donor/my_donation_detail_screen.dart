import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fud360/models/donation.dart';
import 'package:fud360/providers/donation_provider.dart';
import 'package:fud360/theme/app_theme.dart';
import 'package:fud360/widgets/custom_button.dart';
import 'package:intl/intl.dart';

class MyDonationDetailScreen extends StatefulWidget {
  final String donationId;
  
  const MyDonationDetailScreen({
    Key? key,
    required this.donationId,
  }) : super(key: key);

  @override
  State<MyDonationDetailScreen> createState() => _MyDonationDetailScreenState();
}

class _MyDonationDetailScreenState extends State<MyDonationDetailScreen> {
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadDonation();
  }
  
  Future<void> _loadDonation() async {
    final donationProvider = Provider.of<DonationProvider>(context, listen: false);
    await donationProvider.fetchDonationById(widget.donationId);
  }
  
  Future<void> _completeDonation() async {
    setState(() {
      _isLoading = true;
    });
    
    final donationProvider = Provider.of<DonationProvider>(context, listen: false);
    final success = await donationProvider.completeDonation(widget.donationId);
    
    setState(() {
      _isLoading = false;
    });
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donation marked as completed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final donationProvider = Provider.of<DonationProvider>(context);
    final donation = donationProvider.currentDonation;
    
    if (donationProvider.isLoading || donation == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Donation Details'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food images
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: donation.imageUrls.isEmpty ? 1 : donation.imageUrls.length,
                itemBuilder: (context, index) {
                  return donation.imageUrls.isNotEmpty
                      ? Image.network(
                          donation.imageUrls[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.image_not_supported, color: Colors.grey),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, color: Colors.grey),
                          ),
                        );
                },
              ),
            ),
            
            // Donation details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          donation.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildStatusBadge(donation.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Food type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      donation.foodTypeLabel,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    donation.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Details section
                  const Text(
                    'Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow('Quantity', donation.quantity),
                  _buildDetailRow(
                    'Best Before',
                    DateFormat('MMM d, yyyy h:mm a').format(donation.expiryTime),
                  ),
                  _buildDetailRow('Status', donation.statusLabel),
                  _buildDetailRow('Posted', DateFormat('MMM d, yyyy').format(donation.createdAt)),
                  
                  // Location section
                  const SizedBox(height: 16),
                  const Text(
                    'Pickup Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                donation.location,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                donation.address,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Claim information if claimed
                  if (donation.status == DonationStatus.claimed ||
                      donation.status == DonationStatus.inProgress ||
                      donation.status == DonationStatus.completed) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Claimed By',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[100]!),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text(
                              donation.receiverName?[0] ?? 'R',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  donation.receiverName ?? 'Unknown Receiver',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (donation.claimedAt != null)
                                  Text(
                                    'Claimed on ${DateFormat('MMM d, yyyy').format(donation.claimedAt!)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.phone_outlined),
                            onPressed: () {
                              // Contact receiver functionality
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  // Additional notes if any
                  if (donation.notes != null && donation.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        donation.notes!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  if (donation.status == DonationStatus.claimed ||
                      donation.status == DonationStatus.inProgress) ...[
                    CustomButton(
                      text: 'Mark as Completed',
                      isLoading: _isLoading,
                      onPressed: _completeDonation,
                    ),
                  ] else if (donation.status == DonationStatus.available) ...[
                    CustomButton(
                      text: 'Edit Donation',
                      isOutlined: true,
                      onPressed: () {
                        // Navigate to edit screen
                      },
                    ),
                  ],
                  
                  if (donation.status == DonationStatus.available) ...[
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Cancel Donation',
                      isOutlined: true,
                      onPressed: () {
                        // Cancel donation logic
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusBadge(DonationStatus status) {
    Color badgeColor;
    String statusText;
    
    switch (status) {
      case DonationStatus.available:
        badgeColor = Colors.green;
        statusText = 'Available';
        break;
      case DonationStatus.claimed:
        badgeColor = Colors.blue;
        statusText = 'Claimed';
        break;
      case DonationStatus.inProgress:
        badgeColor = Colors.orange;
        statusText = 'In Progress';
        break;
      case DonationStatus.completed:
        badgeColor = Colors.purple;
        statusText = 'Completed';
        break;
      case DonationStatus.expired:
        badgeColor = Colors.grey;
        statusText = 'Expired';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: badgeColor.withOpacity(0.5)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 14,
          color: badgeColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
