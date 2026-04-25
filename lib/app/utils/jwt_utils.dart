import 'dart:convert';

class JwtUtils {
  static Map<String, dynamic> decodeJWT(String token) {
    final parts = token.split('.');

    if (parts.length != 3) {
      throw Exception('Invalid JWT');
    }

    final payload = parts[1];

    // Base64 normalize
    String normalized = base64.normalize(payload);

    final decodedBytes = base64Url.decode(normalized);

    final decodedString = utf8.decode(decodedBytes);

    return json.decode(decodedString);
  }
}
