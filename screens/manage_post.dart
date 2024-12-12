import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostReportScreen extends StatefulWidget {
  static const id = "/PostReportScreen";

  const PostReportScreen({super.key});

  @override
  State<PostReportScreen> createState() => _PostReportScreenState();
}

class _PostReportScreenState extends State<PostReportScreen> {
  final TextEditingController _searchPostIdController = TextEditingController();
  final TextEditingController _searchMemberIdController = TextEditingController();
  final TextEditingController _searchReportFieldController = TextEditingController();
  bool _isLoadingPosts = false;
  bool _isLoadingReports = false;

  List<dynamic> _postData = [];
  List<dynamic> _reportData = [];

  @override
  void initState() {
    super.initState();
    _fetchAllPosts();
    _fetchAllReports();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<void> _fetchAllPosts() async {
    setState(() => _isLoadingPosts = true);

    try {
      final token = await _getToken();
      if (token == null) {
        _showSnackBar("No token found. Please login again.");
        return;
      }

      final dio = Dio();
      dio.options.headers["Authorization"] = "Bearer $token";

      const url = 'http://ec2-13-234-188-240.ap-south-1.compute.amazonaws.com:9090/api/post';
      final response = await dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _postData = response.data['content'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching all posts: $e");
      _showSnackBar("Failed to fetch posts. Please try again.");
    } finally {
      setState(() => _isLoadingPosts = false);
    }
  }

  Future<void> _fetchPostById(String postId) async {
    setState(() => _isLoadingPosts = true);

    try {
      final token = await _getToken();
      if (token == null) {
        _showSnackBar("No token found. Please login again.");
        return;
      }

      final dio = Dio();
      dio.options.headers["Authorization"] = "Bearer $token";

      final url = 'http://ec2-13-234-188-240.ap-south-1.compute.amazonaws.com:9090/api/post/posts/$postId';
      final response = await dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _postData = [response.data];
        });
      }
    } catch (e) {
      debugPrint("Error fetching post by ID: $e");
      _showSnackBar("Failed to fetch post. Please try again.");
    } finally {
      setState(() => _isLoadingPosts = false);
    }
  }

  Future<void> _fetchAllReports() async {
    setState(() => _isLoadingReports = true);

    try {
      final token = await _getToken();
      if (token == null) {
        _showSnackBar("No token found. Please login again.");
        return;
      }

      final dio = Dio();
      dio.options.headers["Authorization"] = "Bearer $token";

      const url = 'http://ec2-13-234-188-240.ap-south-1.compute.amazonaws.com:9090/api/post/report';
      final response = await dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _reportData = response.data;
        });
      }
    } catch (e) {
      debugPrint("Error fetching all reports: $e");
      _showSnackBar("Failed to fetch reports. Please try again.");
    } finally {
      setState(() => _isLoadingReports = false);
    }
  }

  Future<void> _fetchReportsByPostId(String postId) async {
    setState(() => _isLoadingReports = true);

    try {
      final token = await _getToken();
      if (token == null) {
        _showSnackBar("No token found. Please login again.");
        return;
      }

      final dio = Dio();
      dio.options.headers["Authorization"] = "Bearer $token";

      final url =
          'http://ec2-13-234-188-240.ap-south-1.compute.amazonaws.com:9090/api/post/report?postId=$postId';
      final response = await dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _reportData = response.data;
        });
      }
    } catch (e) {
      debugPrint("Error fetching reports by post ID: $e");
      _showSnackBar("Failed to fetch reports. Please try again.");
    } finally {
      setState(() => _isLoadingReports = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                post["s3ImageUrl"] ?? "",
                width: 120,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                  size: 120,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post["user"]?["name"] ?? "Unknown",
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text("Post ID: ${post["postId"] ?? "-"}", style: const TextStyle(color: Colors.grey)),
                  Text("Member ID: ${post["user"]?["memberId"] ?? "-"}", style: const TextStyle(color: Colors.grey)),
                  Text("Post Date: ${post["addedDate"] ?? "-"}", style: const TextStyle(color: Colors.grey)),
                  Text("Post State: ${post["communityName"] ?? "-"}", style: const TextStyle(color: Colors.grey)),
                  Text("Hotel ID: ${post["title"] ?? "-"}", style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text("Caption:\n${post["content"] ?? "-"}", style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          report["reportDescription"] ?? "Unknown Description",
          style: const TextStyle(color: Colors.white), // White text for title
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Member ID: ${report["memberId"]}",
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              "Post ID: ${report["postId"]}",
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              "Date: ${report["dateTime"]}",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("All Posts & Reports"),
      ),
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "All Posts & Report",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 200,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: TextField(
                          controller: _searchPostIdController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "Search Post ID",
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              _fetchPostById(value);
                            } else {
                              _fetchAllPosts();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 200,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: TextField(
                          controller: _searchMemberIdController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "Search Member ID",
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              _fetchReportsByPostId(value);
                            } else {
                              _fetchAllReports();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _isLoadingPosts ? 5 : _postData.length,
                      itemBuilder: (context, index) {
                        if (_isLoadingPosts) {
                          return const CircularProgressIndicator();
                        }
                        return _buildPostCard(_postData[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "All Reports",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 200,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TextField(
                      controller: _searchReportFieldController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Search Reports",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          // Add logic for searching specific reports
                        } else {
                          _fetchAllReports();
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _isLoadingReports ? 5 : _reportData.length,
                      itemBuilder: (context, index) {
                        if (_isLoadingReports) {
                          return const CircularProgressIndicator();
                        }
                        return _buildReportCard(_reportData[index]);
                      },
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
