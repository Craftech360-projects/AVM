import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:friend_private/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/utils/memories/shoppingsuggestion.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductSuggestionsTab extends StatefulWidget {
  final PageController pageController;
  final int memoryAtIndex;
  final MemoryBloc memoryBloc;

  const ProductSuggestionsTab({
    Key? key,
    required this.pageController,
    required this.memoryAtIndex,
    required this.memoryBloc,
  }) : super(key: key);

  @override
  _ProductSuggestionsTabState createState() => _ProductSuggestionsTabState();
}

class _ProductSuggestionsTabState extends State<ProductSuggestionsTab> {
  bool _isLoading = true;
  List<ProductSuggestion> suggestions = [];

  @override
  void initState() {
    super.initState();
    _fetchSuggestions();
  }

  Future<void> _fetchSuggestions() async {
    final transcript =
        widget.memoryBloc.state.memories[widget.memoryAtIndex].transcript;
    try {
      setState(() => _isLoading = true); // Set loading state to true
      await Future.delayed(
          Duration(milliseconds: 100)); // Small delay to show loading UI

      suggestions = await getProductSuggestions(transcript);
    } catch (e) {
      log("Error fetching product suggestions: $e");
      suggestions = [];
    } finally {
      setState(() => _isLoading = false); // Set loading state to false
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              "Loading, please wait...",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (suggestions.isEmpty) {
      return Center(
        child: Text(
          'No product suggestions available.',
          style: TextStyle(color: const Color.fromARGB(255, 240, 238, 238)),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final productSuggestion = suggestions[index];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              productSuggestion.product,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              productSuggestion.searchQuery,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: 8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.6,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: productSuggestion.suggestions.length,
              itemBuilder: (context, suggestionIndex) {
                final searchResult =
                    productSuggestion.suggestions[suggestionIndex];

                return GestureDetector(
                  onTap: () async {
                    final url = Uri.parse(searchResult.link);
                    if (await canLaunchUrl(url)) {
                      launchUrl(url);
                    } else {
                      log('Could not launch ${searchResult.link}');
                    }
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image of the product or suggestion
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: searchResult.image != null
                                ? Image.network(
                                    searchResult.image!,
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    height: 120,
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.grey[500],
                                      size: 50,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 8),

                          // Title
                          Text(
                            searchResult.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[200],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),

                          // Snippet or description
                          Text(
                            searchResult.snippet,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[200],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),

                          // Link or source name
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: TextButton(
                              onPressed: () async {
                                final url = Uri.parse(searchResult.link);
                                if (await canLaunchUrl(url)) {
                                  launchUrl(url);
                                } else {
                                  log('Could not launch ${searchResult.link}');
                                }
                              },
                              child: Text(
                                'View', // Adjust if needed
                                style:
                                    TextStyle(color: Colors.blue, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}
