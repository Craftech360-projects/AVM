// import 'dart:convert';

// import 'package:capsoul/backend/api_requests/api/server.dart';
// import 'package:capsoul/backend/api_requests/api/shared.dart';
// import 'package:capsoul/backend/schema/plugin.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:http/http.dart' as http;
// import 'package:mockito/mockito.dart';

// import 'server_test.mock.mocks.dart'; // Import generated mocks file

// void main() {
//   group('retrievePlugins', () {
//     late MockClient mockClient;
//     late MockSharedPreferencesUtil mockSharedPrefs;

//     setUp(() {
//       // Initialize the mocks
//       mockClient = MockClient();
//       mockSharedPrefs = MockSharedPreferencesUtil();

//       // Optionally initialize the plugins list in SharedPreferencesUtil
//       when(mockSharedPrefs.pluginsList).thenReturn([]);
//     });

//     test('should return plugins if the API call is successful', () async {
//       // Arrange: Mock the response of the API call
//       final response = {
//         "plugins": [
//           {"id": "plugin1", "name": "Plugin 1"},
//           {"id": "plugin2", "name": "Plugin 2"}
//         ]
//       };

//       // Mock the makeApiCall function
//       when(makeApiCall(
//         url: 'url',
//         headers: {}, // Use an empty map for headers
//         body: '', // Use an empty string for body
//         method: 'GET',
//       )).thenAnswer((_) async => http.Response(jsonEncode(response), 200));

//       // Act: Call the function
//       final plugins = await retrievePlugins();

//       // Assert: Check if the plugins list is populated correctly
//       expect(plugins, isNotEmpty);
//       expect(plugins[0].id, 'plugin1');
//       expect(plugins[1].id, 'plugin2');
//     });

//     test('should return cached plugins if the API call fails', () async {
//       // Arrange: Simulate a failed API call by returning an empty response
//       when(makeApiCall(
//         url:
//             'https://raw.githubusercontent.com/Craftech360-projects/AVM/main/community-plugins.json',
//         headers: {}, // Use an empty map for headers
//         body: '', // Use an empty string for body
//         method: 'GET',
//       )).thenAnswer((_) async => http.Response('', 404));

//       // Arrange: Populate the shared preferences with some sample plugins
//       mockSharedPrefs.pluginsList = [
//         Plugin(
//             id: '1',
//             name: 'Plugin 1',
//             author: 'Author 1',
//             description: 'Description 1',
//             image: 'image.png',
//             capabilities: {"memories", "chat"},
//             ratingCount: 5,
//             deleted: false),
//         Plugin(
//             id: '2',
//             name: 'Plugin 2',
//             author: 'Author 2',
//             description: 'Description 2',
//             image: 'image2.png',
//             capabilities: {"memories", "chat"},
//             ratingCount: 10,
//             deleted: false)
//       ];

//       // Act: Call the function
//       final plugins = await retrievePlugins();

//       // Assert: Ensure cached plugins are returned
//       expect(plugins, isNotEmpty);
//       expect(plugins[0].id, '1'); // Verify the plugin ID from cache
//     });

//     test('should return empty list if JSON parsing fails', () async {
//       // Arrange: Simulate a successful API call, but with incorrect JSON format
//       final invalidJsonResponse = '{invalid_json}';

//       when(makeApiCall(
//         url:
//             'https://raw.githubusercontent.com/Craftech360-projects/AVM/main/community-plugins.json',
//         headers: {}, // Use an empty map for headers
//         body: '', // Use an empty string for body
//         method: 'GET',
//       )).thenAnswer((_) async => http.Response(invalidJsonResponse, 200));

//       // Act: Call the function
//       final plugins = await retrievePlugins();

//       // Assert: Check that no plugins are returned
//       expect(plugins, isEmpty);
//     });

//     test('should return empty list if the status code is not 200', () async {
//       // Arrange: Mock an API response with a non-200 status code
//       final response = {"message": "Error occurred"};

//       when(makeApiCall(
//         url:
//             'https://raw.githubusercontent.com/Craftech360-projects/AVM/main/community-plugins.json',
//         headers: {}, // Use an empty map for headers
//         body: '', // Use an empty string for body
//         method: 'GET',
//       )).thenAnswer((_) async => http.Response(jsonEncode(response), 400));

//       // Act: Call the function
//       final plugins = await retrievePlugins();

//       // Assert: Ensure an empty list is returned
//       expect(plugins, isEmpty);
//     });
//   });
// }
