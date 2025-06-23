import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jaibee/secrets.dart';

Future<String> fetchFinancialAdvice(String prompt) async {
  final response = await http.post(
    Uri.parse('https://api.openai.com/v1/chat/completions'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $openAiApiKey',
    },
    body: json.encode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "user", "content": prompt},
      ],
      "temperature": 0.7,
    }),
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
    return jsonResponse['choices'][0]['message']['content'];
  } else {
    throw Exception(
      'Failed to fetch advice: ${response.body}, Please contact the developer: jaibee.care@gmail.com',
    );
  }
}