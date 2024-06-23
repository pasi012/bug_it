import 'package:budg_it/webview_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _itemController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;
  bool _isLoadingText = false;

  // Replace with your Google API key and Custom Search Engine ID
  final String apiKey = 'AIzaSyB-U5ouCkM6wrdOUEVlWMad4I7fWXa5RPA';
  final String searchEngineId = 'd2ec53030479e47f5';

  Future<void> _searchItems() async {
    setState(() {
      _isLoading = true;
      _isLoadingText = true;
    });

    final budget = _budgetController.text;
    final item = _itemController.text;

    // Construct the query with the budget
    final String query = '$item under \$$budget';

    // Construct the Google Custom Search API URL
    final String apiUrl =
        'https://www.googleapis.com/customsearch/v1?key=$apiKey&cx=$searchEngineId&q=$query&num=10';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Map<String, dynamic>> items = (data['items'] as List)
            .map((item) => {
                  'title': item['title'],
                  'link': item['link'],
                  'image': item['pagemap']['cse_image'] != null &&
                          item['pagemap']['cse_image'].isNotEmpty
                      ? item['pagemap']['cse_image'][0]['src']
                      : null,
                })
            .toList();

        setState(() {
          _results = items;
        });
      } else {
        // Handle errors
        throw Exception('Failed to load search results');
      }
    } catch (e) {
      print(e);
      // Handle network or parsing errors
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    print('Trying to launch $url');

    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      print('Could not launch $url');
      throw 'Could not launch $url';
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 15.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xffFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xffFFFFFF),
        title: const Center(
            child: Text(
          'Budg It',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _budgetController,
              decoration: InputDecoration(
                labelText: 'Budget',
                labelStyle: const TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.bold),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                hintText: 'Enter the Budget',
                hintStyle: const TextStyle(color: Colors.grey),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _itemController,
              decoration: InputDecoration(
                labelText: 'Item Name',
                labelStyle: const TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.bold),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                hintText: 'Enter the item name',
                hintStyle: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_itemController.text.isEmpty ||
                      _budgetController.text.isEmpty) {
                    _showToast('Please enter both item name and budget');
                  } else {
                    _searchItems();
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: const Text('Search'),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              _isLoadingText == true ? "Products Match Your Budget" : "",
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.blue),
            ),
            const SizedBox(
              height: 10,
            ),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: _results.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Please Search Product',
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                                Image.asset('assets/no-data.gif',
                                    width: 300, height: 300),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: ScrollController(),
                            itemCount: _results.length,
                            itemBuilder: (context, index) {
                              final result = _results[index];
                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: ListTile(
                                  leading: result['image'] != null
                                      ? Image.network(result['image'],
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.fill)
                                      : Image.network(
                                          "https://yt3.googleusercontent.com/ytc/AIdro_n1E-FM2L6VTnsbi1VoXZEsGLxJoHfc3Xu4Ed7MlaQMH_s=s176-c-k-c0x00ffffff-no-rj",
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.fill,
                                        ),
                                  title: Text(
                                    result['title'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          WebViewScreen(url: result['link']),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}
