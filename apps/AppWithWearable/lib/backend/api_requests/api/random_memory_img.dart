import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

Future<Uint8List> getImage() async {
  const String apiConstant = 'api.api-ninjas.com';
  final url =
      Uri.https(apiConstant, 'v1/randomimage', {'category': 'technology'});
  final response = await http.get(
    url,
    headers: {'X-Api-Key': 'hyycFNEH/Vm8bgpyjZ+eMQ==LUHnunq2o4QrWbr3'},
  );

  if (response.statusCode == 200) {
    String base64String = response.body;
    Uint8List bytes = base64Decode(base64String);

    return bytes;
  } else {
    throw Exception('Failed to load image');
  }
}
