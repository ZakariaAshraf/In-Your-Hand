import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../config/app_keys.dart';

class GeminiQuotaException implements Exception {
  final String message;
  const GeminiQuotaException(this.message);
}

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: geminiApiKey.isEmpty ? 'dummy' : geminiApiKey,
    );
  }

  /// Returns true if a non-empty API key is configured.
  static bool get isConfigured => geminiApiKey.isNotEmpty;


  String _cleanJson(String rawText) {
    String cleaned = rawText.replaceAll('```json', '').replaceAll('```', '');
    return cleaned.trim();
  }

  /// Converts speech transcript to order JSON using Gemini.
  /// Returns a map with: clientName (String), description (String),
  /// totalAmount (num), totalPaid (num, default 0). Returns null on failure.
  Future<Map<String, dynamic>?> speechTextToOrderJson(String transcript) async {
    if (transcript.trim().isEmpty) return null;
    if (!isConfigured) return null;
    try {
      const prompt = '''
You are an assistant that extracts order details from spoken text (Arabic or English).
Return ONLY a raw JSON object (no markdown, no code blocks) with exactly these keys:
- "clientName": string (name of the client/customer)
- "description": string (what the order is for)
- "totalAmount": number (total order amount)
- "totalPaid": number (amount already paid, use 0 if not mentioned)

If something is unclear, use empty string for text and 0 for numbers.
Example output: {"clientName":"Ahmed","description":"5 boxes","totalAmount":500,"totalPaid":0}
''';
      final content = [Content.text('$prompt\n\nSpoken text:\n$transcript')];
      final response = await _model.generateContent(content);
      final responseText = response.text;
      if (responseText == null) return null;
      final cleanText = _cleanJson(responseText);
      final map = jsonDecode(cleanText) as Map<String, dynamic>;
      return map;
    } catch (e) {
      if (kDebugMode) {
        print('Gemini speechToOrder error: $e');
      }
      final errorText = e.toString().toLowerCase();
      if (errorText.contains('quota') ||
          errorText.contains('429') ||
          errorText.contains('rate')) {
        throw GeminiQuotaException(e.toString());
      }
      return null;
    }
  }
}
