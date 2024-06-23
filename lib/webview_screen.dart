import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;

  const WebViewScreen({super.key, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late WebViewController controller;
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await controller.canGoBack()) {
          controller.goBack();
          return false; // Prevent exiting the app
        }
        return true; // Allow exiting the app
      },
      child: Scaffold(
        backgroundColor: const Color(0xffFFFFFF),
        appBar: AppBar(
          backgroundColor: const Color(0xffFFFFFF),
          title: const Center(
            child: Text(
              'Budg It',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                controller.reload();
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            WebView(
              backgroundColor: const Color(0xFFf6f6f7),
              initialUrl: widget.url,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                controller = webViewController;
              },
              onPageFinished: (url) {
                setState(() {
                  isLoading = false;
                });
              },
              gestureNavigationEnabled: true,
            ),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
