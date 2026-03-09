import 'dart:convert';
import 'dart:io';

class NetworkProbeTarget {
  const NetworkProbeTarget({required this.label, required this.uri});

  final String label;
  final Uri uri;
}

class NetworkProbeResult {
  const NetworkProbeResult({
    required this.label,
    required this.uri,
    required this.success,
    required this.statusCode,
    required this.summary,
    required this.latency,
  });

  final String label;
  final Uri uri;
  final bool success;
  final int? statusCode;
  final String summary;
  final Duration latency;
}

class NetworkProbeService {
  const NetworkProbeService();

  static final defaultTargets = <NetworkProbeTarget>[
    NetworkProbeTarget(label: 'Example', uri: Uri.parse('https://example.com')),
    NetworkProbeTarget(label: 'JSON Placeholder', uri: Uri.parse('https://jsonplaceholder.typicode.com/todos/1')),
    NetworkProbeTarget(label: 'GitHub Raw', uri: Uri.parse('https://raw.githubusercontent.com/flutter/flutter/master/README.md')),
  ];

  Future<List<NetworkProbeResult>> probeDefaults() async {
    return Future.wait(defaultTargets.map(probe));
  }

  Future<NetworkProbeResult> probe(NetworkProbeTarget target) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    final watch = Stopwatch()..start();

    try {
      final request = await client.getUrl(target.uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json, text/plain, text/html');
      request.headers.set(HttpHeaders.userAgentHeader, 'FlixNest/1.0');

      final response = await request.close();
      final body = await utf8.decoder.bind(response).join();
      watch.stop();

      return NetworkProbeResult(
        label: target.label,
        uri: target.uri,
        success: response.statusCode >= 200 && response.statusCode < 400,
        statusCode: response.statusCode,
        summary: _summarize(body),
        latency: watch.elapsed,
      );
    } catch (error) {
      watch.stop();
      return NetworkProbeResult(
        label: target.label,
        uri: target.uri,
        success: false,
        statusCode: null,
        summary: error.toString(),
        latency: watch.elapsed,
      );
    } finally {
      client.close(force: true);
    }
  }

  String _summarize(String payload) {
    final compact = payload.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.isEmpty) {
      return 'Empty response';
    }
    return compact.length <= 96 ? compact : '${compact.substring(0, 93)}...';
  }
}
