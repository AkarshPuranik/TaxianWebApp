import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HotelExtranetPage extends StatefulWidget {
  final String hotelId; // Hotel ID passed from the previous page

  const HotelExtranetPage({Key? key, required this.hotelId}) : super(key: key);

  @override
  State<HotelExtranetPage> createState() => _HotelExtranetPageState();
}

class _HotelExtranetPageState extends State<HotelExtranetPage> {
  final _partialTacController = TextEditingController();
  final _gstController = TextEditingController();
  final _serviceRateController = TextEditingController();

  List<Map<String, String>> _additionalDiscounts = [];
  final _propertyController = TextEditingController();
  final _policyController = TextEditingController();
  final _cancellationPolicyController = TextEditingController();
  final _nearbyLocations = <Map<String, String>>[];

  Map<String, dynamic>? _adminAuthorityData;
  Map<String, dynamic>? _currentDetails;

  bool _isLoading = false;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<void> fetchAdminAuthority() async {
    setState(() => _isLoading = true);

    try {
      final token = await _getToken();
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await dio.get(
          'http://ec2-13-234-188-240.ap-south-1.compute.amazonaws.com:9090/api/hotels/getHotelCharges/${widget.hotelId}');
      if (response.statusCode == 200) {
        setState(() {
          _adminAuthorityData = response.data['data'];
        });
      }
    } catch (e) {
      debugPrint('Error fetching admin authority: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> fetchCurrentDetails() async {
    setState(() => _isLoading = true);

    try {
      final token = await _getToken();
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await dio.get(
          'http://ec2-13-234-188-240.ap-south-1.compute.amazonaws.com:9090/api/hotels/${widget.hotelId}/discount');
      if (response.statusCode == 200) {
        setState(() {
          _currentDetails = response.data['data'];
        });
      }
    } catch (e) {
      debugPrint('Error fetching current details: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> saveAdminAuthority() async {
    try {
      final token = await _getToken();
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final body = {
        'partialTAC': _partialTacController.text,
        'gstForPartialTAC': _gstController.text,
        'serviceRateOnRoomRate': _serviceRateController.text,
      };

      await dio.post(
        'http://ec2-13-234-188-240.ap-south-1.compute.amazonaws.com:9090/api/hotels/saveHotelCharges/${widget.hotelId}',
        data: body,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Admin authority updated successfully")),
      );
    } catch (e) {
      debugPrint('Error saving admin authority: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update admin authority")),
      );
    }
  }

  Future<void> saveDiscountDetails() async {
    try {
      final token = await _getToken();
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final body = {'additionalDiscounts': _additionalDiscounts};

      await dio.post(
        'http://ec2-13-234-188-240.ap-south-1.compute.amazonaws.com:9090/api/hotels/save/discount/${widget.hotelId}',
        data: body,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Discount details updated successfully")),
      );
    } catch (e) {
      debugPrint('Error saving discount details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update discount details")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAdminAuthority();
    fetchCurrentDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Extranet'),
        backgroundColor: Colors.grey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Left Panel
            Expanded(
              flex: 2,
              child: ListView(
                children: [
                  _buildSectionHeader('Admin authority for hotels'),
                  _buildTextField('Partial TAC (%)', _partialTacController),
                  _buildTextField('GST for Partial TAC (%)', _gstController),
                  _buildTextField(
                      'Service Rate on Room Rate (%)', _serviceRateController),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: saveAdminAuthority,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                    ),
                    child: const Text('Submit'),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader('Update Details'),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                    ),
                    child: const Text('Upload Images'),
                  ),
                  const SizedBox(height: 16),
                  ..._buildAdditionalDiscountFields(),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _additionalDiscounts.add({'name': '', 'percentage': ''});
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                    ),
                    child: const Text('Add More'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: saveDiscountDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                    ),
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Right Panel
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Current Admin Authority'),
                  if (_adminAuthorityData != null) ...[
                    _buildDetailRow(
                        'Partial TAC (%)', _adminAuthorityData?['partialTAC']),
                    _buildDetailRow('GST (%)',
                        _adminAuthorityData?['gstForPartialTAC']),
                    _buildDetailRow('Service Rate (%)',
                        _adminAuthorityData?['serviceRateOnRoomRate']),
                  ],
                  const SizedBox(height: 16),
                  _buildSectionHeader('Current Details'),
                  if (_currentDetails != null) ...[
                    _buildDetailRow('Discount Details',
                        _currentDetails?['additionalDiscounts']),
                    // Add other details as per the API response
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          border: const OutlineInputBorder(),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        '$label: ${value ?? 'N/A'}',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  List<Widget> _buildAdditionalDiscountFields() {
    return _additionalDiscounts.map((discount) {
      final serviceController = TextEditingController();
      final percentageController = TextEditingController();

      return Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: serviceController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Service Name',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              onChanged: (value) {
                discount['name'] = value;
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: TextField(
              controller: percentageController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Percentage (%)',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              onChanged: (value) {
                discount['percentage'] = value;
              },
            ),
          ),
        ],
      );
    }).toList();
  }
}
