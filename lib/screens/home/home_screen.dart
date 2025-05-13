import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fud360/models/user.dart';
import 'package:fud360/providers/auth_provider.dart';
import 'package:fud360/screens/donor/donor_dashboard.dart';
import 'package:fud360/screens/receiver/receiver_dashboard.dart';
import 'package:fud360/screens/volunteer/volunteer_dashboard.dart';
import 'package:fud360/screens/admin/admin_dashboard.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Return the appropriate dashboard based on user role
    switch (user.role) {
      case UserRole.donor:
        return const DonorDashboard();
      case UserRole.receiver:
        return const ReceiverDashboard();
      case UserRole.volunteer:
        return const VolunteerDashboard();
      case UserRole.admin:
        return const AdminDashboard();
      default:
        return const ReceiverDashboard();
    }
  }
}
