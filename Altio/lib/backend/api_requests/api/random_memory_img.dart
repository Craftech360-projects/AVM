import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

Future<Uint8List> getImage() async {
  const String apiConstant = 'api.api-ninjas.com';
  final url =
      Uri.https(apiConstant, 'v1/randomimage', {'category': 'technology'});

  final response = await http.get(
    url,
    headers: {'X-Api-Key': '+PVSQ6phxAnKHW4J4oz+7A==z4NR1q5X6DZ8RBDa'},
  );

  if (response.statusCode == 200) {
    String base64String = response.body;
    Uint8List bytes = base64Decode(base64String);
    return bytes;
  } else {
    throw Exception('Failed to load image');
  }
}

Future<Uint8List> getImageFromPollinations(String prompt,
    {int width = 333, int height = 333, nologo = true}) async {
  // Replace spaces with underscores in the prompt
  String formattedPrompt = prompt.replaceAll(' ', '_');

  // Construct the URL for the Pollinations API with width and height parameters
  final String apiUrl = 'https://pollinations.ai/p/$formattedPrompt';
  final url = Uri.parse('$apiUrl?width=$width&height=$height&nologo=$nologo');

  // Send a GET request to fetch the image
  final response = await http.get(url);

  // Check if the request was successful
  if (response.statusCode == 200) {
    // If successful, return the image bytes
    Uint8List bytes = response.bodyBytes;
    return bytes;
  } else {
    // Handle error response
    throw Exception('Failed to load image');
  }
}

Future<Uint8List> generateImageWithFallback(String prompt) async {
  try {
    // Try to get the image from Pollinations
    return await getImageFromPollinations(prompt);
  } catch (e) {
    // If Pollinations API fails, fallback to getImage()
    return await getImage();
  }
}
