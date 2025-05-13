import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fud360/models/user.dart';
import 'package:fud360/models/donation.dart';
import 'package:fud360/providers/auth_provider.dart';
import 'package:fud360/theme/app_theme.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  bool _isLoading = false;
  
  // Mock data
  final List<Map<String, dynamic>> _users = [
    {
      'id': '1',
      'name': 'Sarah Johnson',
      'email': 'sarah@example.com',
      'role': 'donor',
      'status': 'active',
      'joinedDate': '2025-03-15',
      'donationsCount': 12,
    },
    {
      'id': '2',
      'name': 'Michael Brown',
      'email': 'michael@example.com',
      'role': 'receiver',
      'status': 'active',
      'joinedDate': '2025-03-10',
      'claimsCount': 8,
    },
    {
      'id': '3',
      'name': 'Emma Wilson',
      'email': 'emma@example.com',
      'role': 'volunteer',
      'status': 'active',
      'joinedDate': '2025-03-05',
      'deliveriesCount': 15,
    },
    {
      'id': '4',
      'name': 'David Lee',
      'email': 'david@example.com',
      'role': 'donor',
      'status': 'inactive',
      'joinedDate': '2025-02-28',
      'donationsCount': 3,
    },
  ];
  
  final List<Map<String, dynamic>> _donations = [
    {
      'id': '1',
      'title': 'Leftover Jollof Rice',
      'donor': 'Sarah Johnson',
      'receiver': 'Hope Shelter',
      'status': 'completed',
      'date': '2025-03-20',
    },
    {
      'id': '2',
      'title': 'Fresh Bread and Pastries',
      'donor': 'Golden Bakery',
      'receiver': null,
      'status': 'available',
      'date': '2025-03-20',
    },
    {
      'id': '3',
      'title': 'Vegetable Soup',
      'donor': 'Community Kitchen',
      'receiver': 'Children\'s Home',
      'status': 'in_progress',
      'date': '2025-03-19',
    },
    {
      'id': '4',
      'title': 'Rice and Beans',
      'donor': 'Mama\'s Kitchen',
      'receiver': null,
      'status': 'expired',
      'date': '2025-03-18',
    },
  ];
  
  final List<Map<String, dynamic>> _reports = [
    {
      'id': '1',
      'title': 'Food quality issue',
      'reporter': 'Michael Brown',
      'reportedUser': 'David Lee',
      'status': 'pending',
      'date': '2025-03-19',
    },
    {
      'id': '2',
      'title': 'No-show for pickup',
      'reporter': 'Sarah Johnson',
      'reportedUser': 'Hope Shelter',
      'status': 'resolved',
      'date': '2025-03-17',
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  List<Map<String, dynamic>> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    
    return _users.where((user) {
      return user['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user['email'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }
  
  List<Map<String, dynamic>> get _filteredDonations {
    if (_searchQuery.isEmpty) return _donations;
    
    return _donations.where((donation) {
      return donation['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          donation['donor'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (donation['receiver'] != null && 
           donation['receiver'].toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();
  }
  
  List<Map<String, dynamic>> get _filteredReports {
    if (_searchQuery.isEmpty) return _reports;
    
    return _reports.where((report) {
      return report['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          report['reporter'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          report['reportedUser'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: Column(
        children: [
          // Stats cards
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Users',
                    '124',
                    Icons.people_outline,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Total Donations',
                    '87',
                    Icons.shopping_bag_outlined,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Success Rate',
                    '92%',
                    Icons.bar_chart_outlined,
                    Colors.amber,
                  ),
                ),
              ],
            ),
          ),
          
          // Search box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search users, donations...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryColor,
            tabs: const [
              Tab(text: 'Users'),
              Tab(text: 'Donations'),
              Tab(text: 'Reports'),
            ],
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Users tab
                _buildUsersTab(),
                
                // Donations tab
                _buildDonationsTab(),
                
                // Reports tab
                _buildReportsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUsersTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return _filteredUsers.isEmpty
        ? _buildEmptyState('No users found matching your search.')
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredUsers.length,
            itemBuilder: (context, index) {
              final user = _filteredUsers[index];
              return _buildUserCard(user);
            },
          );
  }
  
  Widget _buildDonationsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return _filteredDonations.isEmpty
        ? _buildEmptyState('No donations found matching your search.')
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredDonations.length,
            itemBuilder: (context, index) {
              final donation = _filteredDonations[index];
              return _buildDonationCard(donation);
            },
          );
  }
  
  Widget _buildReportsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return _filteredReports.isEmpty
        ? _buildEmptyState('No reports found matching your search.')
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredReports.length,
            itemBuilder: (context, index) {
              final report = _filteredReports[index];
              return _buildReportCard(report);
            },
          );
  }
  
  Widget _buildEmptyState(String message) {
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
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
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
  
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: _getRoleColor(user['role']),
              child: Text(
                user['name'][0],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          user['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildRoleBadge(user['role']),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user['email'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Joined: ${_formatDate(user['joinedDate'])}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      _buildStatusBadge(user['status']),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getUserActivity(user),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // View user details
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              minimumSize: const Size(60, 30),
                              textStyle: const TextStyle(fontSize: 12),
                              elevation: 0,
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                            child: const Text('View'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              // Toggle user status
                              setState(() {
                                user['status'] = user['status'] == 'active'
                                    ? 'inactive'
                                    : 'active';
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: user['status'] == 'active'
                                  ? Colors.red[50]
                                  : Colors.green[50],
                              foregroundColor: user['status'] == 'active'
                                  ? Colors.red
                                  : Colors.green,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              minimumSize: const Size(60, 30),
                              textStyle: const TextStyle(fontSize: 12),
                              elevation: 0,
                              side: BorderSide(
                                color: user['status'] == 'active'
                                    ? Colors.red[100]!
                                    : Colors.green[100]!,
                              ),
                            ),
                            child: Text(
                              user['status'] == 'active' ? 'Suspend' : 'Activate',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDonationCard(Map<String, dynamic> donation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    donation['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildDonationStatusBadge(donation['status']),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Donor',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        donation['donor'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Receiver',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        donation['receiver'] ?? '—',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(donation['date']),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // View donation details
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        minimumSize: const Size(60, 30),
                        textStyle: const TextStyle(fontSize: 12),
                        elevation: 0,
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: const Text('View'),
                    ),
                    if (donation['status'] == 'available')
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ElevatedButton(
                          onPressed: () {
                            // Remove donation
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[50],
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            minimumSize: const Size(60, 30),
                            textStyle: const TextStyle(fontSize: 12),
                            elevation: 0,
                            side: BorderSide(color: Colors.red[100]!),
                          ),
                          child: const Text('Remove'),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildReportCard(Map<String, dynamic> report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    report['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildReportStatusBadge(report['status']),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reported by',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        report['reporter'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Against',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        report['reportedUser'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(report['date']),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Review report
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text('Review'),
                ),
                if (report['status'] == 'pending')
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ElevatedButton(
                      onPressed: () {
                        // Mark as resolved
                        setState(() {
                          report['status'] = 'resolved';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        elevation: 0,
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: const Text('Mark Resolved'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getRoleColor(String role) {
    switch (role) {
      case 'donor':
        return Colors.green;
      case 'receiver':
        return Colors.blue;
      case 'volunteer':
        return Colors.purple;
      case 'admin':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
  
  Widget _buildRoleBadge(String role) {
    Color backgroundColor;
    Color textColor;
    
    switch (role) {
      case 'donor':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case 'receiver':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        break;
      case 'volunteer':
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[800]!;
        break;
      case 'admin':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        role.substring(0, 1).toUpperCase() + role.substring(1),
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildStatusBadge(String status) {
    final isActive = status == 'active';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green[100] : Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.substring(0, 1).toUpperCase() + status.substring(1),
        style: TextStyle(
          fontSize: 12,
          color: isActive ? Colors.green[800] : Colors.grey[800],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildDonationStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    
    switch (status) {
      case 'available':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case 'in_progress':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        break;
      case 'completed':
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[800]!;
        break;
      case 'expired':
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.replaceAll('_', ' ').substring(0, 1).toUpperCase() +
            status.replaceAll('_', ' ').substring(1),
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildReportStatusBadge(String status) {
    final isPending = status == 'pending';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPending ? Colors.amber[100] : Colors.green[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.substring(0, 1).toUpperCase() + status.substring(1),
        style: TextStyle(
          fontSize: 12,
          color: isPending ? Colors.amber[800] : Colors.green[800],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  String _getUserActivity(Map<String, dynamic> user) {
    if (user['role'] == 'donor' && user['donationsCount'] != null) {
      return '${user['donationsCount']} donations';
    } else if (user['role'] == 'receiver' && user['claimsCount'] != null) {
      return '${user['claimsCount']} claims';
    } else if (user['role'] == 'volunteer' && user['deliveriesCount'] != null) {
      return '${user['deliveriesCount']} deliveries';
    }
    return '';
  }
  
  String _formatDate(String dateString) {
    final parts = dateString.split('-');
    if (parts.length != 3) return dateString;
    
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${months[month - 1]} $day, $year';
  }
}
