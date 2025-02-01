import 'dart:convert';

import 'package:capsaul/backend/database/transcript_segment.dart';
import 'package:capsaul/backend/schema/plugin.dart';
import 'package:capsaul/env/env.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtil {
  static final SharedPreferencesUtil _instance =
      SharedPreferencesUtil._internal();
  static SharedPreferences? _preferences;
  SharedPreferences? get preferences => _preferences;

  factory SharedPreferencesUtil() {
    return _instance;
  }

  SharedPreferencesUtil._internal();

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static const String _modelKey = 'selectedModel';

  // ✅ Save the selected model
  set selectedModel(String model) => saveString(_modelKey, model);

  // ✅ Retrieve the selected model (DeepSeek as default)
  String get selectedModel =>
      getString(_modelKey) ?? "llama-3.3-70b-versatile";

  set uid(String value) => saveString('uid', value);
  String get uid => getString('uid') ?? '';

  set deviceId(String value) => saveString('deviceId', value);

  String get deviceId => getString('deviceId') ?? '';

  //show device disconnect notification
  bool get showDisconnectionNotification =>
      getBool('showDisconnectionNotification') ?? false;

  set showDisconnectionNotification(bool value) =>
      saveBool('showDisconnectionNotification', value);

  // Notification Permission Tracking
  set notificationPermissionRequested(bool value) =>
      saveBool('notificationPermissionRequested', value);
  bool get notificationPermissionRequested =>
      getBool('notificationPermissionRequested') ?? false;

  // Location Permission Tracking
  set locationPermissionRequested(bool value) =>
      saveBool('locationPermissionRequested', value);
  bool get locationPermissionRequested =>
      getBool('locationPermissionRequested') ?? false;

  // Bluetooth Permission Tracking
  set bluetoothPermissionRequested(bool value) =>
      saveBool('bluetoothPermissionRequested', value);
  bool get bluetoothPermissionRequested =>
      getBool('bluetoothPermissionRequested') ?? false;

  set deviceName(String value) => saveString('deviceName', value);

  String get deviceName => getString('deviceName') ?? '';

  // Add these lines near the other boolean getters and setters

  bool get isDeviceConnected => getBool('isDeviceConnected') ?? false;

  set isDeviceConnected(bool value) => saveBool('isDeviceConnected', value);

  String get openAIApiKey => getString('openaiApiKey') ?? '';

  set openAIApiKey(String value) => saveString('openaiApiKey', value);

  String get deepgramApiKey => getString('deepgramApiKey') ?? '';
  String get groqApiKey => getString('groqApiKey') ?? '';

  set groqApiKey(String value) => saveString('groqApiKey', value);

  set deepgramApiKey(String value) => saveString('deepgramApiKey', value);

  bool get useTranscriptServer => Env.growthbookApiKey == null
      ? false
      : getBool('useTranscriptServer') ?? true;

  set useTranscriptServer(bool value) => saveBool('useTranscriptServer', value);

  String get gcpCredentials => getString('gcpCredentials') ?? '';

  set gcpCredentials(String value) => saveString('gcpCredentials', value);

  String get gcpBucketName => getString('gcpBucketName') ?? '';

  set gcpBucketName(String value) => saveString('gcpBucketName', value);

  String get webhookOnMemoryCreated => getString('webhookUrl') ?? '';

  set webhookOnMemoryCreated(String value) => saveString('webhookUrl', value);
// Getter for isPromptSaved
  bool get isPromptSaved => getBool('isPromptSaved') ?? false;

// Setter for isPromptSaved
  set isPromptSaved(bool value) => saveBool('isPromptSaved', value);

  String get webhookOnTranscriptReceived =>
      getString('transcriptServerUrl') ?? '';

  set webhookOnTranscriptReceived(String value) =>
      saveString('transcriptServerUrl', value);

  String get recordingsLanguage => getString('recordingsLanguage') ?? 'en';

  set recordingsLanguage(String value) =>
      saveString('recordingsLanguage', value);

  bool get useCapsaulApiKeys => getBool('useCapsaulApiKeys') ?? true;

  set useCapsaulApiKeys(bool value) => saveBool('useCapsaulApiKeys', value);

  bool get onboardingCompleted => getBool('onboardingCompleted') ?? false;

  set onboardingCompleted(bool value) => saveBool('onboardingCompleted', value);

  String get customWebsocketUrl => getString('customWebsocketUrl') ?? '';

  set customWebsocketUrl(String value) =>
      saveString('customWebsocketUrl', value);

  String gptCompletionCache(String key) =>
      getString('gptCompletionCache:$key') ?? '';

  setGptCompletionCache(String key, String value) =>
      saveString('gptCompletionCache:$key', value);

  bool get optInAnalytics => getBool('optInAnalytics') ?? true;

  set optInAnalytics(bool value) => saveBool('optInAnalytics', value);

  bool get devModeEnabled => getBool('devModeEnabled') ?? false;

  set devModeEnabled(bool value) => saveBool('devModeEnabled', value);

  bool get coachNotificationIsChecked => getBool('coachIsChecked') ?? true;

  set coachNotificationIsChecked(bool value) =>
      saveBool('coachIsChecked', value);

  bool get postMemoryNotificationIsChecked =>
      getBool('postMemoryNotificationIsChecked') ?? true;

  set postMemoryNotificationIsChecked(bool value) =>
      saveBool('postMemoryNotificationIsChecked', value);

  bool get reconnectNotificationIsChecked =>
      getBool('reconnectNotificationIsChecked') ?? true;

  set reconnectNotificationIsChecked(bool value) =>
      saveBool('reconnectNotificationIsChecked', value);

  List<String> get recordingPaths => getStringList('recordingPaths') ?? [];

  set recordingPaths(List<String> value) =>
      saveStringList('recordingPaths', value);

  bool get hasSpeakerProfile => getBool('hasSpeakerProfile') ?? false;

  set hasSpeakerProfile(bool value) => saveBool('hasSpeakerProfile', value);

  List<Plugin> get pluginsList {
    final List<String> plugins = getStringList('pluginsList') ?? [];
    return Plugin.fromJsonList(plugins.map((e) => jsonDecode(e)).toList());
  }

  set pluginsList(List<Plugin> value) {
    final List<String> plugins =
        value.map((e) => jsonEncode(e.toJson())).toList();
    saveStringList('pluginsList', plugins);
  }

  List<String> get pluginsEnabled => getStringList('pluginsEnabled') ?? [];

  set pluginsEnabled(List<String> value) =>
      saveStringList('pluginsEnabled', value);

  enablePlugin(String value) {
    final List<String> pluginsId = pluginsEnabled;
    pluginsId.add(value);
    pluginsEnabled = pluginsId;

    final List<Plugin> plugins = pluginsList;
    final plugin = plugins.firstWhere((element) => element.id == value);
    plugin.enabled = true;
    pluginsList = plugins;
  }

  disablePlugin(String value) {
    if (value == selectedChatPluginId) selectedChatPluginId = 'no_selected';
    final List<String> pluginsId = pluginsEnabled;
    pluginsId.remove(value);
    pluginsEnabled = pluginsId;

    final List<Plugin> plugins = pluginsList;
    final plugin = plugins.firstWhere((element) => element.id == value);
    plugin.enabled = false;
    pluginsList = plugins;
  }

  String get selectedChatPluginId =>
      getString('selectedChatPluginId2') ?? 'no_selected';

  set selectedChatPluginId(String value) =>
      saveString('selectedChatPluginId2', value);

  List<TranscriptSegment> get transcriptSegments {
    final List<String> segments = getStringList('transcriptSegments') ?? [];
    return segments
        .map((e) => TranscriptSegment.fromJson(jsonDecode(e)))
        .toList();
  }

  set transcriptSegments(List<TranscriptSegment> value) {
    final List<String> segments =
        value.map((e) => jsonEncode(e.toJson())).toList();
    saveStringList('transcriptSegments', segments);
  }

  String get lastDailySummaryDay => getString('lastDailySummaryDate') ?? '';

  set lastDailySummaryDay(String value) =>
      saveString('lastDailySummaryDate', value);

  Future<bool> saveString(String key, String value) async {
    return await _preferences?.setString(key, value) ?? false;
  }

  String? getString(String key) {
    return _preferences?.getString(key);
  }

  //Bot Notification Plugin
  bool get notificationPlugin => getBool('notificationPlugin') ?? false;
  set notificationPlugin(bool value) => saveBool('notificationPlugin', value);

  Future<bool> saveInt(String key, int value) async {
    return await _preferences?.setInt(key, value) ?? false;
  }

  int? getInt(String key) {
    return _preferences?.getInt(key);
  }

  Future<bool> saveBool(String key, bool value) async {
    return await _preferences?.setBool(key, value) ?? false;
  }

  bool? getBool(String key) {
    return _preferences?.getBool(key);
  }

  bool get tosAccepted => getBool('tosAccepted') ?? false;

  set tosAccepted(bool value) => saveBool('tosAccepted', value);

  bool get backupsEnabled => getBool('backupsEnabled2') ?? false;

  set backupsEnabled(bool value) => saveBool('backupsEnabled2', value);

  bool get hasSeenTutorial =>
      getBool('hasSeenTutorial') ?? true; // ===> CHANGE TO FALSE

  set hasSeenTutorial(bool value) => saveBool('hasSeenTutorial', value);

  Future<bool> saveApiType(String key, String value) async {
    return await _preferences?.setString(key, value) ?? false;
  }

  Future<bool> saveCodecType(String key, String value) async {
    return await _preferences?.setString(key, value) ?? false;
  }

  Future<bool> updateKeywordDetectionStatus(String key, String value) async {
    return await _preferences?.setString(key, value) ?? false;
  }

  String? getApiType(String key) {
    return _preferences?.getString(key);
  }

  String getCodecType(String key) {
    return _preferences?.getString(key) ?? 'opus';
  }

  Future<bool> saveDouble(String key, double value) async {
    return await _preferences?.setDouble(key, value) ?? false;
  }

  double? getDouble(String key) {
    return _preferences?.getDouble(key);
  }

  Future<bool> saveStringList(String key, List<String> value) async {
    return await _preferences?.setStringList(key, value) ?? false;
  }

  List<String>? getStringList(String key) {
    return _preferences?.getStringList(key);
  }

  String getKeywordDetectionStatus(String key) {
    return _preferences?.getString(key) ?? 'off';
  }

  List<String> getSelectedKeywords() {
    return _preferences?.getStringList('selectedKeywords') ?? [];
  }

  Future<bool> saveSelectedPrompt(String key, String selectedValue) async {
    return await _preferences?.setString(key, selectedValue) ?? false;
  }

  String? getSelectedPrompt(String key) {
    return _preferences?.getString(key);
  }

  Future<bool> remove(String key) async {
    return await _preferences?.remove(key) ?? false;
  }

  Future<bool> clear() async {
    return await _preferences?.clear() ?? false;
  }

  set scriptCategoriesAndEmojisExecuted(bool value) =>
      saveBool('scriptCategoriesAndEmojisExecuted', value);

  bool get scriptCategoriesAndEmojisExecuted =>
      getBool('scriptCategoriesAndEmojisExecuted') ?? false;

  set scriptMemoryVectorsExecuted(bool value) =>
      saveBool('scriptMemoryVectorsExecuted2', value);

  bool get scriptMemoryVectorsExecuted =>
      getBool('scriptMemoryVectorsExecuted2') ?? false;

  set scriptMemoriesToObjectBoxExecuted(bool value) =>
      saveBool('scriptMemoriesToObjectBoxExecuted', value);

  bool get scriptMemoriesToObjectBoxExecuted =>
      getBool('scriptMemoriesToObjectBoxExecuted') ?? false;

  set pageToShowFromNotification(int value) =>
      saveInt('pageToShowFromNotification', value);

  int get pageToShowFromNotification =>
      getInt('pageToShowFromNotification') ?? 0;

  set subPageToShowFromNotification(String value) =>
      saveString('subPageToShowFromNotification', value);

  String get subPageToShowFromNotification =>
      getString('subPageToShowFromNotification') ?? '';

  set calendarEnabled(bool value) => saveBool('calendarEnabled', value);

  bool get calendarEnabled => getBool('calendarEnabled') ?? false;
  set developerOptionEnabled(bool value) => saveBool('developerEnabled', value);

  bool get developerOptionEnabled => getBool('developerEnabled') ?? false;

  set calendarId(String value) => saveString('calendarId', value);

  String get calendarId => getString('calendarId') ?? '';

  set calendarType(String value) =>
      saveString('calendarType', value); // auto, manual

  String get calendarType => getString('calendarType') ?? 'auto';

  bool get firstTranscriptMade => getBool('firstTranscriptMade') ?? false;

  set firstTranscriptMade(bool value) => saveBool('firstTranscriptMade', value);

  // AUTH

  String get authToken => getString('authToken') ?? '';

  set authToken(String value) => saveString('authToken', value);

  String get email => getString('email') ?? '';

  set email(String value) => saveString('email', value);

  String get givenName => getString('givenName') ?? '';

  set givenName(String value) => saveString('givenName', value);

  String get familyName => getString('familyName') ?? '';

  set familyName(String value) => saveString('familyName', value);

  String get fullName => '$givenName $familyName';

  set zapierApiKey(String value) => saveString('zapierApiKey', value);

  String get zapierApiKey => getString('zapierApiKey') ?? '';

  set zapierWebhookUrl(String value) => saveString('zapierWebhookUrl', value);

  String get zapierWebhookUrl => getString('zapierWebhookUrl') ?? '';

  set zapierEnabled(bool value) => saveBool('zapierEnabled', value);

  bool get zapierEnabled => getBool('zapierEnabled') ?? false;
}

String getOpenAIApiKeyForUsage() => SharedPreferencesUtil().openAIApiKey.isEmpty
    ? Env.openAIAPIKey!
    : SharedPreferencesUtil().openAIApiKey;

String getDeepgramApiKeyForUsage() =>
    SharedPreferencesUtil().deepgramApiKey.isEmpty
        ? Env.deepgramApiKey!
        : SharedPreferencesUtil().deepgramApiKey;
