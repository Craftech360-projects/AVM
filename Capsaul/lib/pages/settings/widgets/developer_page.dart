import 'dart:developer';

import 'package:capsaul/backend/database/prompt_provider.dart';
import 'package:capsaul/backend/preferences.dart';
import 'package:capsaul/core/assets/app_images.dart';
import 'package:capsaul/core/constants/constants.dart';
import 'package:capsaul/core/theme/app_colors.dart';
import 'package:capsaul/features/capture/logic/websocket_mixin.dart';
import 'package:capsaul/pages/home/custom_scaffold.dart';
import 'package:capsaul/pages/settings/widgets/custom_expandible_widget.dart';
import 'package:capsaul/pages/settings/widgets/custom_prompt_page.dart';
import 'package:capsaul/pages/settings/widgets/firmware_screen.dart';
import 'package:capsaul/pages/settings/widgets/keywords_popup.dart';
import 'package:flutter/material.dart';

class DeveloperPage extends StatefulWidget {
  const DeveloperPage({super.key});
  static const name = "developer";

  @override
  State<DeveloperPage> createState() => _DeveloperPageState();
}

class _DeveloperPageState extends State<DeveloperPage> with WebSocketMixin {
  String _currentApiType = '';
  String _currentCodecType = '';
  String _currentKeywordStatus = '';
  bool _developerEnabled = false;
  bool _isPromptSaved = false;
  final List<String> previouslySelected =
      SharedPreferencesUtil().getSelectedKeywords();
  Set<String> selectedKeywords = {};

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    selectedKeywords.addAll(previouslySelected);
  }

  void _loadPreferences() {
    _developerEnabled = SharedPreferencesUtil().developerOptionEnabled;
    _isPromptSaved = SharedPreferencesUtil().isPromptSaved;
    _currentApiType = SharedPreferencesUtil().getApiType('NewApiKey') ?? '';
    _currentCodecType = SharedPreferencesUtil().getCodecType('NewCodec');
    _currentKeywordStatus = SharedPreferencesUtil()
        .getKeywordDetectionStatus('newKeywordDetectionStatus');
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      showBackBtn: true,
      showGearIcon: true,
      title: const Text(
        "Developer Options",
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      children: [
        _buildDeveloperSwitch(),
        h4,
        if (!_developerEnabled)
          _buildDeveloperDescription()
        else
          _buildDeveloperOptions(),
      ],
    );
  }

  Widget _buildDeveloperSwitch() {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.purpleDark,
                child: Icon(Icons.people, color: AppColors.commonPink),
              ),
              w16,
              Text(
                'Developer Options',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ],
          ),
          Switch(
            inactiveTrackColor: AppColors.white,
            activeTrackColor: AppColors.purpleDark,
            activeColor: AppColors.commonPink,
            activeThumbImage: AssetImage(AppImages.appLogo),
            value: _developerEnabled,
            onChanged: _handleDeveloperModeToggle,
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: const Text(
          'By Enabling Developer Mode You can customize prompts & Transcript Services',
          textAlign: TextAlign.center),
    );
  }

  Widget _buildDeveloperOptions() {
    final codecType = SharedPreferencesUtil().getCodecType('NewCodec');

    return Column(
      children: [
        if (codecType == 'pcm') _buildTranscriptServiceTile(),
        _buildPromptTile(),
        _buildCodecTile(),
        _buildKeywordDetectionTile(),
        _buildFirmwareScreen(),
      ],
    );
  }

  void _handleDeveloperModeToggle(bool value) {
    if (!value) {
      SharedPreferencesUtil().saveApiType('NewApiKey', 'Default');
      PromptProvider().removeAllPrompts();
      SharedPreferencesUtil().isPromptSaved = false;
    }

    SharedPreferencesUtil().developerOptionEnabled = value;
    setState(() => _developerEnabled = value);
  }

  Future<void> _handleServiceSelection(String service) async {
    closeWebSocket();
    developerModeSelected(modeSelected: service);
    await _reconnectWebSocket();
  }

  Widget _buildPromptTile() {
    return CustomExpansionTile(
      title: 'Prompt Settings',
      subtitle: _isPromptSaved ? 'Saved' : 'Not Saved',
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.greyLight),
                  borderRadius: br12),
              child: const Text('Manage Prompts')),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CustomPromptPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTranscriptServiceTile() {
    return CustomExpansionTile(
      title: 'Transcript Service',
      subtitle: _currentApiType,
      children: [
        for (final service in ['Deepgram', 'Sarvam', 'Whisper'])
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(color: AppColors.greyLight),
                    borderRadius: br12),
                child: Text(service)),
            onTap: () => _handleServiceSelection(service),
          ),
      ],
    );
  }

  Widget _buildCodecTile() {
    return CustomExpansionTile(
      title: 'Codec Type',
      subtitle: _currentCodecType.toUpperCase(),
      children: [
        for (final codec in ['pcm', 'opus'])
          ListTile(
            title: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.greyLight),
                  borderRadius: br12),
              child: Text(
                codec.toUpperCase(),
              ),
            ),
            contentPadding: EdgeInsets.zero,
            onTap: () => codecSelected(modeSelected: codec),
          ),
      ],
    );
  }

  Widget _buildFirmwareScreen() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => FirmwareScreen()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15),
        decoration:
            BoxDecoration(color: AppColors.commonPink, borderRadius: br8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Firmware Settings",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Check for new updates",
                  style: TextStyle(
                    fontSize: 14,
                  ),
                )
              ],
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildKeywordDetectionTile() {
    return CustomExpansionTile(
      title: 'Keyword Detection',
      subtitle: _currentKeywordStatus.toUpperCase(),
      children: [
        for (final status in ['ON', 'OFF'])
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.greyLight),
                  borderRadius: br12),
              child: Text(
                status,
              ),
            ),
            onTap: () => updateKeywordDetectionStatus(modeSelected: status),
          ),
      ],
    );
  }

  void developerModeSelected({required String modeSelected}) {
    SharedPreferencesUtil().saveApiType('NewApiKey', modeSelected);
    avmSnackBar(context, "New changes have been applied");
    if (mounted) {
      setState(() {});
    }
    _reconnectWebSocket();
  }

  void codecSelected({required String modeSelected}) {
    SharedPreferencesUtil().saveCodecType('NewCodec', modeSelected);
    if (mounted) {
      setState(() {
        _currentCodecType = modeSelected;
      });
    }
    avmSnackBar(context, "New changes have been applied");
    _reconnectWebSocket();
  }

  Future<void> _reconnectWebSocket() async {
    try {
      await initWebSocket(
        onConnectionClosed: (closeCode, closeReason) {
          if (mounted) {
            setState(() {});
          }
        },
        onConnectionSuccess: () {
          if (mounted) {
            setState(() {});
          }
        },
        onConnectionError: (_) {},
        onConnectionFailed: (_) {},
        onMessageReceived: (_) {},
      );
    } catch (e) {
      log(e.toString());
    }
  }

  void updateKeywordDetectionStatus({required String modeSelected}) async {
    if (modeSelected == 'ON') {
      final List<String>? userSelectedKeywords = await showDialog<List<String>>(
        context: context,
        builder: (context) =>
            KeywordsDialog(initialSelectedKeywords: selectedKeywords),
      );

      // Check if user selected keywords and saved
      if (userSelectedKeywords != null && userSelectedKeywords.isNotEmpty) {
        // Save selected keywords to preferences
        final keywordStatusSaved =
            await SharedPreferencesUtil().updateKeywordDetectionStatus(
          'newKeywordDetectionStatus',
          modeSelected,
        );

        await SharedPreferencesUtil().preferences?.setStringList(
              'selectedKeywords',
              userSelectedKeywords,
            );

        if (keywordStatusSaved) {
          setState(() {
            _currentKeywordStatus = modeSelected;
            selectedKeywords = userSelectedKeywords.toSet();
          });
        }
      } else {
        // Do not enable if no keywords selected
        return;
      }
    } else {
      // Disable keyword detection
      await SharedPreferencesUtil().updateKeywordDetectionStatus(
        'newKeywordDetectionStatus',
        modeSelected,
      );
      setState(() {
        _currentKeywordStatus = modeSelected;
      });
    }
  }

  @override
  void dispose() {
    closeWebSocket();
    super.dispose();
  }
}
