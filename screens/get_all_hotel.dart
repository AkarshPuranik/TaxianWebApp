import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxian_super_admin_web/screens/extranet.dart';


class HotelDetailsPage extends StatefulWidget {
  static const String id = '/hotelDetails'; // Unique route name for this page

  const HotelDetailsPage({Key? key}) : super(key: key);

  @override
  State<HotelDetailsPage> createState() => _HotelDetailsPageState();
}

class _HotelDetailsPageState extends State<HotelDetailsPage> {
  final TextEditingController _hotelIdController = TextEditingController();
  final TextEditingController _hotelNameController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _hotelData;

  Future<void> fetchHotelDetails(String hotelId) async {
    setState(() {
      _isLoading = true;
      _hotelData = null; // Reset the data before fetching
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No token found. Please log in again.")),
        );
        return;
      }

      final dio = Dio();
      dio.options.headers["Authorization"] = "Bearer $token";

      final response = await dio.get(
        'http://ec2-13-234-188-240.ap-south-1.compute.amazonaws.com:9090/api/hotels/$hotelId',
      );

      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _hotelData = response.data['data']; // Store API response data
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.data['message'] ?? 'Unable to fetch details.'}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          // Permanent Sidebar
          Container(
            width: 250, // Sidebar width
            color: Colors.grey[850], // Sidebar background color
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.grey),
                _buildSidebarItem(Icons.dashboard, 'Dashboard'),
                _buildSidebarItem(Icons.people, 'Manage B2C Users'),
                _buildSidebarItem(Icons.post_add, 'Manage Post'),
                _buildSidebarItem(Icons.location_on, 'Add Area - Community'),
                _buildSidebarItem(Icons.verified, 'Doc. Verify'),
                _buildSidebarItem(Icons.hotel, 'All Hotels', isSelected: true),
                _buildSidebarItem(Icons.book, 'Hotel Booking'),
                const Divider(color: Colors.grey),
                _buildSidebarItem(Icons.group, 'Manage Team'),
                _buildSidebarItem(Icons.settings, 'Settings'),
                _buildSidebarItem(Icons.logout, 'Log Out'),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.black,
                title: const Text('All Hotels', style: TextStyle(color: Colors.white)),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Search Fields Row
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _hotelIdController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Hotel ID',
                              labelStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _hotelNameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Hotel Name',
                              labelStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final hotelId = _hotelIdController.text.trim();
                            if (hotelId.isNotEmpty) {
                              fetchHotelDetails(hotelId);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Please enter a Hotel ID.")),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                          ),
                          child: const Text('Search', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Hotel Details and Action Buttons
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator(color: Colors.white))
                            : (_hotelData != null
                            ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Hotel Details Column
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow('Hotel ID', _hotelData?['hotelId']?.toString() ?? 'N/A'),
                                  _buildDetailRow('Hotel Name', _hotelData?['hotelName'] ?? 'N/A'),
                                  _buildDetailRow('Hotel Address', _hotelData?['hotelAddress'] ?? 'N/A'),
                                  _buildDetailRow('Category', _hotelData?['category'] ?? 'N/A'),
                                  _buildDetailRow('Owner Mbl. No.', _hotelData?['hotelOwnerMobileNumber'] ?? 'N/A'),
                                  _buildDetailRow('Email ID', _hotelData?['email'] ?? 'N/A'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Action Buttons Row
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildActionButton('Extranet'),
                                  const SizedBox(height: 8),
                                  _buildActionButton('Update mobile & email'),
                                  const SizedBox(height: 8),
                                  _buildActionButton('Booking'),
                                  const SizedBox(height: 8),
                                  _buildActionButton('Update Hotel category'),
                                  const SizedBox(height: 8),
                                  _buildStatusButton(),
                                ],
                              ),
                            ),
                          ],
                        )
                            : const Center(
                          child: Text(
                            'No Data Available',
                            style: TextStyle(color: Colors.white),
                          ),
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String label, {bool isSelected = false}) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.white : Colors.grey),
      title: Text(
        label,
        style: TextStyle(color: isSelected ? Colors.white : Colors.grey),
      ),
      tileColor: isSelected ? Colors.grey[700] : null,
      onTap: () {
        // Handle navigation here
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label) {
    return ElevatedButton(
      onPressed: () {
        if (label == 'Extranet') {
          // Navigate to the HotelExtranetPage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HotelExtranetPage(hotelId: '',)), // Navigate to HotelExtranetPage
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[800],
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _buildStatusButton() {
    return ElevatedButton(
      onPressed: () {
        // Handle status change logic here
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
      ),
      child: const Text('Active', style: TextStyle(color: Colors.white)),
    );
  }
}
