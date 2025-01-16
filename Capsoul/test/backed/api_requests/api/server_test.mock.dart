import 'package:capsoul/backend/preferences.dart';
import 'package:mockito/annotations.dart';
import 'package:capsoul/backend/api_requests/api/shared.dart';
import 'package:http/http.dart' as http;

@GenerateMocks([http.Client, SharedPreferencesUtil])
void main() {}
