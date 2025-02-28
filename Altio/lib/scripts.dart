import 'package:altio/backend/api_requests/api/pinecone.dart';
import 'package:altio/backend/database/memory_provider.dart';
import 'package:altio/backend/preferences.dart';

Future<void> scriptMemoryVectorsExecuted() async {
  // FUCK, there was a very stupid issue.
  // vectors were overwritten for each user, as the id of the vector was the memory id of the local db (0,1,2...)
  // This aims to fix that
  if (SharedPreferencesUtil().scriptMemoryVectorsExecuted) return;

  var memories = MemoryProvider().getMemoriesOrdered();
  if (memories.isEmpty) {
    SharedPreferencesUtil().scriptMemoryVectorsExecuted = true;
    return;
  }
  // for (var i = 0; i < memories.length; i++) {
  //   var f = getEmbeddingsFromInput(memories[i].structured.toString())
  //       .then((vector) {
  //     upsertPineconeVector(
  //         memories[i].id.toString(), vector, memories[i].createdAt);
  //   });
  //   if (i % 10 == 0) {
  //     await f;
  //     await Future.delayed(const Duration(seconds: 1));
  //   }
  // }

  SharedPreferencesUtil().scriptMemoryVectorsExecuted = true;
}
