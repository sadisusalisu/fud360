import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fud360/providers/donation_provider.dart';
import 'package:fud360/providers/auth_provider.dart';
import 'package:fud360/screens/receiver/browse_donations_screen.dart';
import 'package:fud360/screens/receiver/donation_detail_screen.dart';
import 'package:fud360/screens/notifications/notifications_screen.dart';
import 'package:fud360/screens/profile/profile_screen.dart';
import 'package:fud360/theme/app_theme.dart';
import 'package:fud360/widgets/donation_card.dart';

class ReceiverDashboard extends StatefulWidget {
  const ReceiverDashboard({Key? key}) : super(key: key);

  @override
  State<ReceiverDashboard> createState() => _ReceiverDashboardState();
}

class _ReceiverDashboardState extends State<ReceiverDashboard> {
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    final donationProvider = Provider.of<DonationProvider>(context, listen: false);
    await donationProvider.fetchDonations();
    await donationProvider.fetchMyClaimedDonations();
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final donationProvider = Provider.of<DonationProvider>(context);
    final user = authProvider.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fud360'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Text(
                  'Hello, ${user?.name.split(' ').first ?? 'Receiver'}!',
                  style: AppTheme.headingStyle,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Find available food donations nearby',
                  style: AppTheme.captionStyle,
                ),
                const SizedBox(height: 24),
                
                // Available donations section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Available Donations',
                      style: AppTheme.subheadingStyle,
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BrowseDonationsScreen()),
                        );
                      },
                      icon: const Icon(Icons.search, size: 18),
                      label: const Text('Browse All'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Available donations list
                donationProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : donationProvider.donations.isEmpty
                        ? _buildEmptyAvailableDonations()
                        : SizedBox(
                            height: 300,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: donationProvider.donations.length > 5
                                  ? 5
                                  : donationProvider.donations.length,
                              itemBuilder: (context, index) {
                                final donation = donationProvider.donations[index];
                                return Container(
                                  width: 280,
                                  margin: const EdgeInsets.only(right: 16),
                                  child: DonationCard(
                                    donation: donation,
                                    isHorizontal: true,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => DonationDetailScreen(donationId: donation.id),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                const SizedBox(height: 32),
                
                // My claimed donations section
                const Text(
                  'My Claimed Donations',
                  style: AppTheme.subheadingStyle,
                ),
                const SizedBox(height: 16),
                
                // My claimed donations list
                donationProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : donationProvider.myClaimedDonations.isEmpty
                        ? _buildEmptyClaimedDonations()
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: donationProvider.myClaimedDonations.length,
                            itemBuilder: (context, index) {
                              final donation = donationProvider.myClaimedDonations[index];
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
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BrowseDonationsScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyAvailableDonations() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No donations available nearby',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check back later or expand your search area',
              style: TextStyle(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyClaimedDonations() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No claimed donations yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Browse available donations and claim them',
              style: TextStyle(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BrowseDonationsScreen()),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text('Browse Donations'),
            ),
          ],
        ),
      ),
    );
  }
}
