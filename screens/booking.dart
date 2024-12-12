import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingDetailsPage extends StatefulWidget {
  static const String id = '/bookingDetails'; // Unique ID for navigation

  @override
  _BookingDetailsPageState createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  String? bearerToken;
  Map<String, dynamic>? bookingDetails;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bearerToken = prefs.getString('bearer_token');
    });
  }

  Future<void> _fetchBookingDetails(String memberId, String bookingId) async {
    if (bearerToken == null) return;

    try {
      Dio dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $bearerToken';
      final response = await dio.get(
        'http://ec2-13-234-188-240.ap-south-1.compute.amazonaws.com:9090/api/hotels/booking/getAllBookings',
        queryParameters: {
          'memberId': memberId,
          'bookingStatus': 'Booking Confirmed',
          'bookingId': bookingId,
        },
      );

      setState(() {
        bookingDetails = response.data;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
      ),
      body: bookingDetails == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            Text('Booking Status: ${bookingDetails!['status']}'),
            Text('Booking ID: ${bookingDetails!['bookingId']}'),
            Text('Booking Date & Time: ${bookingDetails!['dateTime']}'),
            const SizedBox(height: 20),
            const Text('Hotel Details', style: TextStyle(fontSize: 20)),
            Text('Hotel Name: ${bookingDetails!['hotelName']}'),
            Text('Hotel ID: ${bookingDetails!['hotelId']}'),
            Text('Address: ${bookingDetails!['address']}'),
            Text('Property Roles: ${bookingDetails!['propertyRoles']}'),
            Text('Pricing: ${bookingDetails!['pricing']}'),
            Text('Room Plan Details: ${bookingDetails!['roomPlanDetails']}'),
            Text('Total Rooms: ${bookingDetails!['totalRooms']}'),
            Text('Adults: ${bookingDetails!['adults']}'),
            Text('Children: ${bookingDetails!['children']}'),
            Text('Check-in Date: ${bookingDetails!['checkInDate']}'),
            Text('Check-out Date: ${bookingDetails!['checkOutDate']}'),
            Text('Traveler Name: ${bookingDetails!['travelerName']}'),
            Text('Mobile No: ${bookingDetails!['mobileNo']}'),
            Text('Email: ${bookingDetails!['email']}'),
            const Text('Full Payment Details:'),
            Text('Order ID: ${bookingDetails!['fullPayment']['orderId']}'),
            Text('Paid Amount: ${bookingDetails!['fullPayment']['paidAmount']}'),
            Text('Cancellation Policy: ${bookingDetails!['fullPayment']['cancellationPolicy']}'),
            const Text('Partial Payment Details:'),
            Text('Order ID: ${bookingDetails!['partialPayment']['orderId']}'),
            Text('Partial Paid Amount: ${bookingDetails!['partialPayment']['partialPaidAmount']}'),
            Text('Due Amount: ${bookingDetails!['partialPayment']['dueAmount']}'),
            Text('Cancellation Policy: ${bookingDetails!['partialPayment']['cancellationPolicy']}'),
          ],
        ),
      ),
    );
  }
}
