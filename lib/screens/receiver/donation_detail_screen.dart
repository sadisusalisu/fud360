import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fud360/models/donation.dart';
import 'package:fud360/providers/donation_provider.dart';
import 'package:fud360/theme/app_theme.dart';
import 'package:fud360/widgets/custom_button.dart';
import 'package:intl/intl.dart';

class DonationDetailScreen extends StatefulWidget {
  final String donationId;

  const DonationDetailScreen({
    Key? key,
    required this.donationId,
  }) : super(key: key);

  @override
  State<DonationDetailScreen> createState() => _DonationDetailScreenState();
}

class _DonationDetailScreenState extends State<DonationDetailScreen> {
  bool _isLoading = false;
  final TextEditingController _notesController = TextEditingController();
  bool _acceptTerms = false;

  @override
  void initState() {
    super.initState();
    _loadDonation();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadDonation() async {
    final donationProvider = Provider.of<DonationProvider>(context, listen: false);
    await donationProvider.fetchDonationById(widget.donationId);
  }

  Future<void> _claimDonation() async {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the terms')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final donationProvider = Provider.of<DonationProvider>(context, listen: false);
    final notes = _notesController.text.isEmpty ? null : _notesController.text;

    final success = await donationProvider.claimDonation(widget.donationId, notes);

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donation claimed successfully')),
      );
    }
  }

  void _showClaimDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Claim'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'You\'re about to claim this food donation. Please provide any additional information for the donor.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Pickup Notes (Optional)',
                  hintText: 'E.g., I\'ll arrive in 30 minutes, I\'m wearing a blue shirt, etc.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: (value) {
                      setState(() {
                        _acceptTerms = value ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'I confirm that I will pick up this donation within the specified time frame and use it for its intended purpose.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _claimDonation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Confirm Claim'),
          ),
        ],
      ),
    );
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

    final isClaimed = donation.status != DonationStatus.available || donation.isExpired;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // Share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Image gallery
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              ],
            ),
            const SizedBox(height: 8),

            Text(
              donation.quantity,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),

            // Expiry time row
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: donation.isExpired ? Colors.red[50] : Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: donation.isExpired ? Colors.red : Colors.amber[800],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          donation.isExpired ? 'Expired' : 'Best Before',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: donation.isExpired ? Colors.red : Colors.amber[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('EEEE, MMMM d, y h:mm a').format(donation.expiryTime),
                          style: TextStyle(
                            color: donation.isExpired ? Colors.red[700] : Colors.amber[900],
                          ),
                        ),
                        if (!donation.isExpired) ...[
                          const SizedBox(height: 4),
                          Text(
                            donation.timeLeft,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.amber[900],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
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
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Location
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
            const SizedBox(height: 24),

            // Donor info
            const Text(
              'Donor',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      donation.donorName?[0] ?? 'D',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          donation.donorName ?? 'Anonymous',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Text(
                          'Verified Donor',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.message_outlined),
                    onPressed: () {
                      // Message donor
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Notes
            if (donation.notes != null && donation.notes!.isNotEmpty) ...[
        const Text(
        'Additional Notes',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        donation.notes!,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
        ),
      ),
              const SizedBox(height: 24),
            ],
      Text(
        donation.notes!,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
        ),
      ),
      const SizedBox(height: 24),
      ],
    ),
    ),

    ],
    ),
    ),
    bottomNavigationBar: Padding(
    padding: const EdgeInsets.all(16.0),
    child: CustomButton(
    text: isClaimed ? 'Already Claimed' : 'Claim Donation',
    onPressed: isClaimed ? () {} : _showClaimDialog,
    isLoading: _isLoading,
    ),
    ),
    );
  }
}
