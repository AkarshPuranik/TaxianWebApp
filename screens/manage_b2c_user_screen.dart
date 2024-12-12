import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxian_super_admin_web/screens/dashboard.dart';
import 'package:taxian_super_admin_web/style/pallet.dart';

class ManageB2CUserScreen extends StatefulWidget {
  static const id = "/ManageB2CUserScreen";

  const ManageB2CUserScreen({super.key});

  @override
  State<ManageB2CUserScreen> createState() => _ManageB2CUserScreenState();
}

class _ManageB2CUserScreenState extends State<ManageB2CUserScreen> {
  final TextEditingController _mobileNumberController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _userData = [];

  Future<void> _fetchUserByMobile(String mobileNumber) async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No token found. Please login again.")),
        );
        return;
      }

      final dio = Dio();
      dio.options.headers["Authorization"] = "Bearer $token";

      final response = await dio.get(
          'http://ec2-13-234-188-240.ap-south-1.compute.amazonaws.com:9090/api/users/submit/mobile/$mobileNumber');

      if (response.statusCode == 200 && response.data != null && response.data is Map<String, dynamic>) {
        setState(() {
          _userData = [response.data];
        });
      } else {
        setState(() {
          _userData = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No user found.")),
        );
      }
    } catch (e) {
      debugPrint("Error fetching user: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch data. Please try again.")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildSearchRow() {
    return Row(
      children: [
        // Mobile Number Input
        Expanded(
          child: TextField(
            controller: _mobileNumberController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              hintText: "Mobile No.",
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Search Button
        ElevatedButton(
          onPressed: () {
            final mobileNumber = _mobileNumberController.text.trim();
            if (mobileNumber.isNotEmpty) {
              _fetchUserByMobile(mobileNumber);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Enter a valid mobile number.")),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[700],
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            "Search",
            style: TextStyle(
              color: Colors.amber, // Matches the style in your image
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStaticMenu() {
    return Container(
      width: 250,
      color: Pallet.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
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
          _buildNavItem(Icons.dashboard, "Dashboard", isActive: false, onTap: () {
            Navigator.pushNamed(context, DashboardScreen.id);
          }),
          _buildNavItem(Icons.people, "Manage B2C Users", isActive: true, onTap: () {}),
          _buildNavItem(Icons.post_add, "Manage Post", isActive: false, onTap: () {}),
          _buildNavItem(Icons.location_city, "Add Area", isActive: false, onTap: () {}),
          _buildNavItem(Icons.verified, "Document Verify", isActive: false, onTap: () {}),
          _buildNavItem(Icons.hotel, "All Hotels", isActive: false, onTap: () {}),
          _buildNavItem(Icons.book, "Hotel Booking", isActive: false, onTap: () {}),
          const Spacer(),
          _buildNavItem(Icons.settings, "Settings", isActive: false, onTap: () {}),
          _buildNavItem(Icons.logout, "Log Out", isActive: false, onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, {required bool isActive, required VoidCallback onTap}) {
    return Container(
      decoration: isActive
          ? BoxDecoration(
        color: Pallet.darkGrey,
        borderRadius: BorderRadius.circular(8),
      )
          : null,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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

  Widget _buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.grey[900]),
        columnSpacing: 20,
        dataRowColor: MaterialStateProperty.all(Colors.grey[850]),
        columns: const [
          DataColumn(
              label: Text(
                "Member ID",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
          DataColumn(
              label: Text(
                "Name",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
          DataColumn(
              label: Text(
                "PAN No.",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
          DataColumn(
              label: Text(
                "Mobile No.",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
          DataColumn(
              label: Text(
                "Mail ID",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
        ],
        rows: _userData.map((user) {
          return DataRow(
            cells: [
              DataCell(Text(user["memberId"] ?? "-", style: const TextStyle(color: Colors.white))),
              DataCell(Text(user["name"] ?? "-", style: const TextStyle(color: Colors.white))),
              DataCell(Text(user["pan_number"] ?? "No verified",
                  style: TextStyle(
                      color: user["pan_number"]?.isEmpty ?? true ? Colors.red : Colors.white))),
              DataCell(Text(user["mobileNumber"] ?? "-", style: const TextStyle(color: Colors.white))),
              DataCell(Text(user["email_id"] ?? "-", style: const TextStyle(color: Colors.white))),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Static sidebar
          _buildStaticMenu(),
          // Main content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Pallet.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchRow(), // Search row added here
                  const SizedBox(height: 20),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_userData.isNotEmpty)
                    Expanded(
                      child: _buildTable(),
                    )
                  else
                    const Center(
                      child: Text(
                        "Enter a mobile number to fetch user details.",
                        style: TextStyle(color: Colors.white),
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
}
