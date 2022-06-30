import 'dart:convert';

class ParseUtils {
  const ParseUtils._();

  static Map<String, dynamic>? parseStringToMap(String? payload) {
    if (payload == null) {
      return null;
    }
    try {
      return jsonDecode(payload);
    } catch (error) {
      return null;
    }
  }
}
