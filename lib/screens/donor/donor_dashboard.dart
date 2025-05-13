import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fud360/providers/donation_provider.dart';
import 'package:fud360/providers/auth_provider.dart';
import 'package:fud360/screens/donor/create_donation_screen.dart';
import 'package:fud360/screens/donor/my_donation_detail_screen.dart';
import 'package:fud360/screens/notifications/notifications_screen.dart';
import 'package:fud360/screens/profile/profile_screen.dart';
import 'package:fud360/theme/app_theme.dart';
import 'package:fud360/widgets/donation_card.dart';
import 'package:fud360/widgets/impact_stats_card.dart';

class DonorDashboard extends StatefulWidget {
  const DonorDashboard({Key? key}) : super(key: key);

  @override
  State<DonorDashboard> createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    final donationProvider = Provider.of<DonationProvider>(context, listen: false);
    await donationProvider.fetchMyDonations();
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
                  'Hello, ${user?.name.split(' ').first ?? 'Donor'}!',
                  style: AppTheme.headingStyle,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Thank you for sharing your surplus food',
                  style: AppTheme.captionStyle,
                ),
                const SizedBox(height: 24),
                
                // Impact stats
                const ImpactStatsCard(),
                const SizedBox(height: 24),
                
                // My donations section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Donations',
                      style: AppTheme.subheadingStyle,
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CreateDonationScreen()),
                        );
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Donate Food'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Tabs for active/past donations
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[700],
                    tabs: const [
                      Tab(text: 'Active'),
                      Tab(text: 'Past'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Tab content
                SizedBox(
                  height: 400, // Fixed height for tab content
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Active donations
                      donationProvider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : donationProvider.myDonations.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: donationProvider.myDonations.length,
                                  itemBuilder: (context, index) {
                                    final donation = donationProvider.myDonations[index];
                                    return DonationCard(
                                      donation: donation,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => MyDonationDetailScreen(donationId: donation.id),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                      
                      // Past donations
                      const Center(
                        child: Text('No past donations found'),
                      ),
                    ],
                  ),
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
              MaterialPageRoute(builder: (_) => const CreateDonationScreen()),
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
            icon: Icon(Icons.add_circle_outline),
            label: 'Donate',
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
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No active donations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start sharing your surplus food with those in need',
            style: TextStyle(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateDonationScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Donate Food'),
          ),
        ],
      ),
    );
  }
}
