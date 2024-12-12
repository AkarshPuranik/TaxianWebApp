import 'package:flutter/material.dart';
import 'package:taxian_super_admin_web/screens/booking.dart';
import 'package:taxian_super_admin_web/screens/get_all_hotel.dart';
import 'package:taxian_super_admin_web/screens/manage_b2c_user_screen.dart';
import 'package:taxian_super_admin_web/screens/manage_post.dart';
import 'package:taxian_super_admin_web/style/pallet.dart';

class DashboardScreen extends StatelessWidget {
  static const id = "/DashboardScreen";

  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Permanent Sidebar Navigation
          Container(
            width: 250,
            color: Pallet.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sidebar Header
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Pallet.primary,
                  child: const Text(
                    'Admin Panel',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Pallet.secondary,
                    ),
                  ),
                ),
                const Divider(color: Pallet.secondary, thickness: 1),

                // Navigation Menu Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(10),
                    children: [
                      _buildNavItem(
                        context,
                        Icons.dashboard,
                        "Dashboard",
                        isActive: true,
                        onTap: () {
                          Navigator.pushNamed(context, DashboardScreen.id);
                        },
                      ),
                      _buildNavItem(
                        context,
                        Icons.people,
                        "Manage B2C Users",
                        onTap: () {
                          Navigator.pushNamed(context, ManageB2CUserScreen.id);
                        },
                      ),
                      _buildNavItem(
                        context,
                        Icons.post_add,
                        "Manage Post",
                        onTap: () {
                         Navigator.pushNamed(context, PostReportScreen.id);
                        },
                      ),
                      _buildNavItem(
                        context,
                        Icons.map,
                        "Add Area - Community",
                        onTap: () {
                          // Add navigation logic for Add Area - Community
                        },
                      ),
                      _buildNavItem(
                        context,
                        Icons.verified_user,
                        "Doc. Verify",
                        onTap: () {
                          // Add navigation logic for Doc. Verify
                        },
                      ),
                      _buildNavItem(
                        context,
                        Icons.hotel,
                        "All Hotels",
                        onTap: () {
                         Navigator.pushNamed(context,  HotelDetailsPage.id );
                        },
                      ),
                      _buildNavItem(
                        context,
                        Icons.book,
                        "Hotel Booking",
                        onTap: () {
                          Navigator.pushNamed(context, BookingDetailsPage.id);
                        },
                      ),
                      const Divider(color: Pallet.secondary),
                      _buildNavItem(
                        context,
                        Icons.group,
                        "Manage Team",
                        onTap: () {
                          // Add navigation logic for Manage Team
                        },
                      ),
                      _buildNavItem(
                        context,
                        Icons.settings,
                        "Settings",
                        onTap: () {
                          // Add navigation logic for Settings
                        },
                      ),
                      _buildNavItem(
                        context,
                        Icons.logout,
                        "Log Out",
                        onTap: () {
                          // Add logout logic
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Dashboard Content Area
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              color: Pallet.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dashboard Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Pallet.secondary,
                        ),
                      ),
                      const Icon(Icons.account_circle, color: Pallet.secondary, size: 40),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Dashboard Content
                  const Text(
                    "This is the dashboard main content area where highlights and API data can be shown.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Pallet.secondary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Placeholder Content
                  Expanded(
                    child: Center(
                      child: Text(
                        "Welcome to the Dashboard",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Pallet.secondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper for Navigation Items
  Widget _buildNavItem(BuildContext context, IconData icon, String label,
      {required VoidCallback onTap, bool isActive = false}) {
    return Container(
      decoration: isActive
          ? BoxDecoration(
        color: Pallet.darkGrey,
        borderRadius: BorderRadius.circular(8),
      )
          : null,
      child: ListTile(
        leading: Icon(icon, color: isActive ? Pallet.secondary : Pallet.lightGrey),
        title: Text(
          label,
          style: TextStyle(
            color: isActive ? Pallet.secondary : Pallet.lightGrey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
