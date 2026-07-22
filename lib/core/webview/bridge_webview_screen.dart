import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Generic WebView for anything reached via the Phase 4 session-bridge ticket
/// mechanism — Paymob checkout (Phase 8) and the lecture player (Phase 9)
/// both use this unchanged, just with a different [initialUrl]/[title] and
/// (for checkout only) an [interceptUrlContains] pattern.
///
/// When [interceptUrlContains] is set, any navigation whose URL contains that
/// substring is cancelled and the screen pops immediately with
/// [interceptSuccess] evaluated against that URL — used so the Paymob
/// callback page is never actually shown; the native app renders its own
/// result instead. When null (the lecture-player case), this screen is just
/// a plain authenticated WebView with a close button — no special pop value.
class BridgeWebViewScreen extends StatefulWidget {
  const BridgeWebViewScreen({
    super.key,
    required this.initialUrl,
    required this.title,
    this.interceptUrlContains,
    this.interceptSuccess,
  });

  final String initialUrl;
  final String title;
  final String? interceptUrlContains;
  final bool Function(Uri url)? interceptSuccess;

  @override
  State<BridgeWebViewScreen> createState() => _BridgeWebViewScreenState();
}

class _BridgeWebViewScreenState extends State<BridgeWebViewScreen> {
  bool _isLoading = true;
  bool _resultReturned = false;

  void _finish([bool? result]) {
    if (_resultReturned) return;
    _resultReturned = true;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Close',
          onPressed: () =>
              _finish(widget.interceptUrlContains != null ? false : null),
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              thirdPartyCookiesEnabled: true,
            ),
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url = navigationAction.request.url.toString();
              final pattern = widget.interceptUrlContains;
              if (pattern != null && url.contains(pattern)) {
                _finish(widget.interceptSuccess?.call(Uri.parse(url)) ?? true);
                return NavigationActionPolicy.CANCEL;
              }
              return NavigationActionPolicy.ALLOW;
            },
            onLoadStart: (controller, url) {
              if (mounted) setState(() => _isLoading = true);
            },
            onLoadStop: (controller, url) {
              if (mounted) setState(() => _isLoading = false);
            },
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
