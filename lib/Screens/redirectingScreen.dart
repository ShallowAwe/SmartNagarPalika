import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatelessWidget {
   final String url;
  const WebViewScreen({super.key,required this.url});

  @override
  Widget build(BuildContext context) {
  
 
    //have to implement the live redirecting webpages as per the users  requirment 
    return Scaffold(
      appBar: AppBar(),
      body: WebViewWidget(controller: 
        WebViewController()..loadRequest(Uri.parse(url))
      ),
    );
  }
}