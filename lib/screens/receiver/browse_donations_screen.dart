import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fud360/models/donation.dart';
import 'package:fud360/providers/donation_provider.dart';
import 'package:fud360/screens/receiver/donation_detail_screen.dart';
import 'package:fud360/theme/app_theme.dart';
import 'package:fud360/widgets/donation_card.dart';

class BrowseDonationsScreen extends StatefulWidget {
  const BrowseDonationsScreen({Key? key}) : super(key: key);

  @override
  State<BrowseDonationsScreen> createState() => _BrowseDonationsScreenState();
}

class _BrowseDonationsScreenState extends State<BrowseDonationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDonations();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadDonations() async {
    final donationProvider = Provider.of<DonationProvider>(context, listen: false);
    await donationProvider.fetchDonations();
  }
  
  List<Donation> _filterDonations(List<Donation> donations) {
    if (_searchQuery.isEmpty) return donations;
    
    return donations.where((donation) {
      return donation.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          donation.donorName!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          donation.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          donation.foodTypeLabel.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }
  
  List<Donation> _sortDonationsByDistance(List<Donation> donations) {
    // Normally would sort by actual distance
    // For mock example, we'll just return the donations as is
    return List.from(donations);
  }
  
  List<Donation> _sortDonationsByRecent(List<Donation> donations) {
    final sorted = List<Donation>.from(donations);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }
  
  List<Donation> _sortDonationsByExpiring(List<Donation> donations) {
    final sorted = List<Donation>.from(donations);
    sorted.sort((a, b) => a.expiryTime.compareTo(b.expiryTime));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Donations'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(104),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by food type, location...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () {
                        // Show filter options
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              
              // Tabs
              TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: 'Nearby'),
                  Tab(text: 'Recent'),
                  Tab(text: 'Expiring Soon'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Consumer<DonationProvider>(
        builder: (context, donationProvider, child) {
          if (donationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final availableDonations = donationProvider.donations
              .where((d) => d.status == DonationStatus.available && !d.isExpired)
              .toList();
          
          return TabBarView(
            controller: _tabController,
            children: [
              // Nearby tab
              _buildDonationsList(
                _filterDonations(_sortDonationsByDistance(availableDonations)),
              ),
              
              // Recent tab
              _buildDonationsList(
                _filterDonations(_sortDonationsByRecent(availableDonations)),
              ),
              
              // Expiring Soon tab
              _buildDonationsList(
                _filterDonations(_sortDonationsByExpiring(availableDonations)),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildDonationsList(List<Donation> donations) {
    if (donations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'No donations available'
                  : 'No donations matching "$_searchQuery"',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'Check back later or expand your search area'
                  : 'Try different keywords or clear your search',
              style: const TextStyle(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
                child: const Text('Clear Search'),
              ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadDonations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: donations.length,
        itemBuilder: (context, index) {
          final donation = donations[index];
          return DonationCard(
            donation: donation,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DonationDetailScreen(donationId: donation.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
