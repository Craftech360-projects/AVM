// // lib/services/product_search_service.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// // These are the models for our response data
// class ProductSuggestion {
//   final String product;
//   final String searchQuery;
//   final List<SearchResult> suggestions;
//   final String? error;

//   ProductSuggestion({
//     required this.product,
//     required this.searchQuery,
//     required this.suggestions,
//     this.error,
//   });
// }

// class SearchResult {
//   final String title;
//   final String link;
//   final String snippet;
//   final String? image;

//   SearchResult({
//     required this.title,
//     required this.link,
//     required this.snippet,
//     this.image,
//   });
// }

// // This is the function you'll call
// Future<List<ProductSuggestion>> getProductSuggestions(String transcript) async {
//   const mistralApiKey =
//       'jLm3AXpqdWYcukdwgua9ILTjdLm1Txn9'; // Replace with your key
//   const googleApiKey =
//       'AIzaSyBBua0qKYX9MVTnI4BeO0pakJ2hR7IqWI8'; // Replace with your key
//   const googleCseId = '022c490db3f2140cb'; // Replace with your ID

//   try {
//     // Clean the transcript
//     final cleanedTranscript = transcript
//         .replaceAll(RegExp(r'[\r\n]+'), ' ')
//         .replaceAll(RegExp(r'\s+'), ' ')
//         .trim();

//     // Get Mistral AI recommendations
//     final mistralResponse = await http.post(
//       Uri.parse('https://api.mistral.ai/v1/chat/completions'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//         'Authorization': 'Bearer $mistralApiKey',
//       },
//       body: jsonEncode({
//         'model': 'mistral-large-latest',
//         'messages': [
//           {
//             'role': 'user',
//             'content':
//                 '''Analyze this meeting transcript and create ONE comprehensive search query per product mentioned.
//               For each product:
//               1. Include specific specs mentioned (CPU, RAM, storage, etc.)
//               2. Include price range if mentioned
//               3. Include brand preferences if mentioned
//               4. Include key requirements (performance, battery life, etc.)

//               Combine all important aspects into a single optimized search query.

//               Transcript: $cleanedTranscript

//               Return a JSON object with this structure:
//               {
//                 "searchQueries": [
//                   {
//                     "product": "string",
//                     "query": "string (single comprehensive search query combining all key requirements)"
//                   }
//                 ]
//               }'''
//           }
//         ],
//         'response_format': {'type': 'json_object'},
//       }),
//     );

//     final mistralData = jsonDecode(mistralResponse.body);
//     final searchQueries =
//         jsonDecode(mistralData['choices'][0]['message']['content']);

//     // Get Google search results
//     final List<ProductSuggestion> productSuggestions = [];

//     for (var query in searchQueries['searchQueries']) {
//       try {
//         final googleResponse = await http.get(
//           Uri.parse('https://www.googleapis.com/customsearch/v1').replace(
//             queryParameters: {
//               'key': googleApiKey,
//               'cx': googleCseId,
//               'q': query['query'],
//               'num': '10',
//             },
//           ),
//         );

//         final googleData = jsonDecode(googleResponse.body);
//         final List<SearchResult> results = [];

//         for (var item in googleData['items']) {
//           results.add(
//             SearchResult(
//               title: item['title'],
//               link: item['link'],
//               snippet: item['snippet'],
//               image: item['pagemap']?['cse_image']?[0]?['src'],
//             ),
//           );
//         }

//         productSuggestions.add(
//           ProductSuggestion(
//             product: query['product'],
//             searchQuery: query['query'],
//             suggestions: results,
//           ),
//         );
//       } catch (e) {
//         productSuggestions.add(
//           ProductSuggestion(
//             product: query['product'],
//             searchQuery: query['query'],
//             suggestions: [],
//             error: 'Failed to fetch suggestions for this product',
//           ),
//         );
//       }
//     }

//     return productSuggestions;
//   } catch (e) {
//     throw Exception('Error processing request: $e');
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductSuggestion {
  final String product;
  final String searchQuery;
  final List<SearchResult> suggestions;
  final String? error;

  ProductSuggestion({
    required this.product,
    required this.searchQuery,
    required this.suggestions,
    this.error,
  });

  // Add a toJson method for better logging
  Map<String, dynamic> toJson() => {
        'product': product,
        'searchQuery': searchQuery,
        'suggestions': suggestions.map((s) => s.toJson()).toList(),
        'error': error,
      };
}

class SearchResult {
  final String title;
  final String link;
  final String snippet;
  final String? image;

  SearchResult({
    required this.title,
    required this.link,
    required this.snippet,
    this.image,
  });

  // Add a toJson method for better logging
  Map<String, dynamic> toJson() => {
        'title': title,
        'link': link,
        'snippet': snippet,
        'image': image,
      };
}

Future<List<ProductSuggestion>> getProductSuggestions(String transcript) async {
  const mistralApiKey = 'jLm3AXpqdWYcukdwgua9ILTjdLm1Txn9';
  const googleApiKey = 'AIzaSyBBua0qKYX9MVTnI4BeO0pakJ2hR7IqWI8';
  const googleCseId = '022c490db3f2140cb';

  try {
    final cleanedTranscript = transcript
        .replaceAll(RegExp(r'[\r\n]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    print('🔍 Processing transcript: $cleanedTranscript');
    print(transcript.length);
    //  if (transcript.length < 35) return [];
    final mistralResponse = await http.post(
      Uri.parse('https://api.mistral.ai/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $mistralApiKey',
      },
      body: jsonEncode({
        'model': 'mistral-large-latest',
        'messages': [
          {
            'role': 'user',
            'content':
                '''Analyze this meeting transcript and create ONE comprehensive search query per product mentioned with latest version.
              For each product:
              1. Include specific specs mentioned (CPU, RAM, storage, etc.)
              2. Include price range if mentioned
              3. Include brand preferences if mentioned
              4. Include key requirements (performance, battery life, etc.)
              
              Combine all important aspects into a single optimized search query.
  
              Transcript: $cleanedTranscript
  
              Return a JSON object with this structure:
              {
                "searchQueries": [
                  {
                    "product": "string",
                    "query": "string (single comprehensive search query combining all key requirements)"
                  }
                ]
              }'''
          }
        ],
        'response_format': {'type': 'json_object'},
      }),
    );

    final mistralData = jsonDecode(mistralResponse.body);
    final searchQueries =
        jsonDecode(mistralData['choices'][0]['message']['content']);

    print('📝 Mistral AI generated queries:');
    print(JsonEncoder.withIndent('  ').convert(searchQueries));

    final List<ProductSuggestion> productSuggestions = [];

    for (var query in searchQueries['searchQueries']) {
      try {
        print('\n🔎 Fetching results for product: ${query['product']}');
        print('Query: ${query['query']}');

        final googleResponse = await http.get(
          Uri.parse('https://www.googleapis.com/customsearch/v1').replace(
            queryParameters: {
              'key': googleApiKey,
              'cx': googleCseId,
              'q': query['query'],
              'num': '6',
            },
          ),
        );

        final googleData = jsonDecode(googleResponse.body);
        final List<SearchResult> results = [];

        for (var item in googleData['items']) {
          results.add(
            SearchResult(
              title: item['title'],
              link: item['link'],
              snippet: item['snippet'],
              image: item['pagemap']?['cse_image']?[0]?['src'],
            ),
          );
        }

        productSuggestions.add(
          ProductSuggestion(
            product: query['product'],
            searchQuery: query['query'],
            suggestions: results,
          ),
        );
      } catch (e) {
        print('❌ Error fetching results for ${query['product']}: $e');
        productSuggestions.add(
          ProductSuggestion(
            product: query['product'],
            searchQuery: query['query'],
            suggestions: [],
            error: 'Failed to fetch suggestions for this product',
          ),
        );
      }
    }

    // Log final results
    print('\n📊 Final Results:');
    print(JsonEncoder.withIndent('  ').convert(
        productSuggestions.map((suggestion) => suggestion.toJson()).toList()));

    return productSuggestions;
  } catch (e) {
    print('❌ Fatal error: $e');
    throw Exception('Error processing request: $e');
  }
}
