import 'dart:convert';

import 'package:capsaul/backend/database/profile_entity.dart';
import 'package:capsaul/backend/database/profile_provider.dart';
import 'package:capsaul/core/constants/constants.dart';
import 'package:capsaul/core/theme/app_colors.dart';
import 'package:capsaul/pages/home/custom_scaffold.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

String fixEmoji(String brokenEmoji) {
  return utf8.decode(latin1.encode(brokenEmoji));
}

class AboutYouScreen extends StatelessWidget {
  const AboutYouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      showRefreshIcon: true,
      showBackBtn: true,
      title: Text(
        "Capsaul Mirror",
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
      ),
      onRefresh: () => context.read<ProfileProvider>().resetProfile(),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          return _ProfileView(profile: provider.profile);
        },
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  final Profile profile;

  const _ProfileView({required this.profile});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildProfileHeader(),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          sliver: SliverGrid(
            delegate: SliverChildListDelegate([
              _buildSentimentRadar(profile),
              _buildSpeechPatterns(),
              _buildProductivityChart(),
              _buildInteractionHeatmap(),
            ]),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 1.2,
              mainAxisSpacing: 40,
            ),
          ),
        ),
        _buildSection(
          'Core Identity',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last Updated: ${DateFormat.yMMMd().format(profile.lastUpdated)}',
                style: const TextStyle(color: AppColors.grey, fontSize: 12),
              ),
              h8,
              Text(
                profile.core,
                style: TextStyle(height: 1.2, fontSize: 13.5),
              ),
            ],
          ),
        ),
        _buildHealthScorecard(),
        _buildListSection('Hobbies', profile.hobbies),
        _buildListSection('Interests', profile.interests),
        _buildListSection('Skills', profile.skills),
        _buildWorkSection(),
        _buildCategoryCloud(),
      ],
    );
  }

  Widget _buildProfileHeader() {
    String fixedEmoji = fixEmoji(profile.emoji);
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.zero,
        margin: EdgeInsets.only(bottom: 20, top: 0),
        child: Text(
          textAlign: TextAlign.center,
          fixedEmoji,
          style: const TextStyle(fontSize: 40, fontFamily: "NotoColorEmoji"),
        ),
      ),
    );
  }

  Widget _buildSentimentRadar(Profile profile) {
    final metrics = profile.conversationMetrics;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: RadarChart(
          RadarChartData(
            dataSets: [
              RadarDataSet(
                dataEntries: [
                  RadarEntry(value: (metrics['sentiment'] ?? 0.0)),
                  RadarEntry(value: (metrics['clarity'] ?? 0.0)),
                  RadarEntry(value: metrics['politeness'] ?? 0.0),
                  RadarEntry(value: metrics['engagement'] ?? 0.0),
                  RadarEntry(value: metrics['empathy'] ?? 0.0),
                ],
                fillColor: AppColors.blue.withValues(alpha: 0.3),
                borderColor: AppColors.blue,
                borderWidth: 2,
              ),
            ],
            radarBackgroundColor: Colors.transparent,
            radarBorderData: BorderSide(color: AppColors.grey, width: 1),
            titlePositionPercentageOffset: 0.2,
            getTitle: (index, angle) {
              final titles = [
                'Sentiment',
                'Clarity',
                'Politeness',
                'Engagement',
                'Empathy'
              ];
              return RadarChartTitle(
                text: titles[index],
                angle: angle,
              );
            },
            titleTextStyle: TextStyle(
              color: AppColors.black,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            tickCount: 5,
            ticksTextStyle: TextStyle(color: AppColors.grey, fontSize: 10),
            tickBorderData: BorderSide(color: AppColors.grey, width: 0.5),
            gridBorderData: BorderSide(color: AppColors.grey, width: 1),
          ),
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        ),
      ),
    );
  }

  Widget _buildSpeechPatterns() {
    final metrics = profile.conversationMetrics;
    print("Metrics =====> $metrics");
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: constraints.maxWidth * 1,
              height: constraints.maxWidth * 0.8,
              constraints: BoxConstraints(
                maxHeight: 300,
              ),
              child: Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegend(AppColors.orange, "Questions"),
                      _buildLegend(AppColors.green, "Statements"),
                    ],
                  ),
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            showTitle: false,
                            value: metrics['questions'] ?? 50.0,
                            color: AppColors.orange,
                          ),
                          PieChartSectionData(
                            showTitle: false,
                            value: metrics['statements'] ?? 50.0,
                            color: AppColors.green,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        w4,
        Text(label),
      ],
    );
  }

  Widget _buildProductivityChart() {
    final metrics = profile.conversationMetrics;

    return LineChart(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, metrics['monday'] ?? 0.0),
              FlSpot(1, metrics['tuesday'] ?? 0.0),
              FlSpot(2, metrics['wednesday'] ?? 0.0),
              FlSpot(3, metrics['thursday'] ?? 0.0),
            ],
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) =>
                  Text(['Mon', 'Tue', 'Wed', 'Thu'][value.toInt()]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractionHeatmap() {
    final metrics = profile.conversationMetrics;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: HeatMap(
        datasets: Map.fromEntries(metrics.entries
            .where((entry) => _isValidDate(entry.key))
            .map((entry) => MapEntry(
                DateFormat('yyyy-MM-dd').parse(entry.key), entry.value))),
        colorMode: ColorMode.opacity,
        showText: true,
        scrollable: true,
        colorsets: {
          1: Colors.blue[100]!,
          3: Colors.blue[300]!,
          5: Colors.blue[600]!,
        },
      ),
    );
  }

  bool _isValidDate(String key) {
    try {
      DateFormat('yyyy-MM-dd').parseStrict(key);
      return true;
    } catch (e) {
      return false;
    }
  }

  Widget _buildMetricRow(String label, double value, Color color) {
    return ListTile(
      title: Text(label),
      trailing: CircularPercentIndicator(
        radius: 20,
        lineWidth: 3,
        percent: value,
        progressColor: color,
        backgroundColor: color.withValues(alpha: 0.1),
        circularStrokeCap: CircularStrokeCap.round,
        center: Text('${(value * 100).toStringAsFixed(0)}%'),
      ),
    );
  }

  Widget _buildHealthScorecard() {
    final metrics = profile.conversationMetrics;

    return SliverPadding(
      padding: EdgeInsets.all(16),
      sliver: SliverToBoxAdapter(
        child: Card(
          child: Column(
            children: [
              _buildMetricRow(
                  'Sentiment', metrics['sentiment'] ?? 0.0, AppColors.green),
              _buildMetricRow(
                  'Empathy', metrics['empathy'] ?? 0.0, AppColors.blue),
              _buildMetricRow('Productivity', metrics['productivity'] ?? 0.0,
                  AppColors.orange),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverToBoxAdapter(
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: br5),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                h8,
                content,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkSection() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Work... 💼",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.blueGreyDark,
              ),
            ),
            if (profile.work.isNotEmpty) Text(profile.work),
            if (profile.skills.isNotEmpty)
              Wrap(
                spacing: 8,
                children: profile.skills
                    .map((skill) => Chip(label: Text(skill)))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildListSection(String title, List<String> items) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      sliver: SliverToBoxAdapter(
        // ✅ Wrap in SliverToBoxAdapter
        child: ExpansionTile(
          title: Text('$title (${items.length})'),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: items
                  .map((item) => Chip(
                        label: Text(item),
                        avatar: const Icon(Icons.label, size: 18),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCloudChip(String category) {
    return PhysicalShape(
      color: const Color.fromARGB(255, 178, 220, 255),
      clipper: CloudClipper(),
      elevation: 3.0,
      shadowColor: Colors.black.withValues(alpha: 0.5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.category, size: 15, color: AppColors.blueGreyDark),
            // w4,
            Text(
              category,
              style:
                  const TextStyle(color: AppColors.blueGreyDark, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCloud() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: AppColors.blue.withValues(alpha: 0.8), width: 1.5),
                borderRadius: br30,
              ),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                "Meet Your Clouds... 🌥️",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blueGreyDark,
                ),
              ),
            ),
            h16,
            Wrap(
              spacing: 4,
              runSpacing: 12,
              children: profile.categories
                  .map((category) => buildCloudChip(category))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class CloudClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    final path = Path();

    // Start at the left center.
    path.moveTo(width * 0.25, height * 0.5);

    // Upper left curve.
    path.cubicTo(0, height * 0.2, width * 0.2, 0, width * 0.5, 0);

    // Upper right curve.
    path.cubicTo(
        width * 0.8, 0, width, height * 0.3, width * 0.85, height * 0.55);

    // Lower right curve.
    path.cubicTo(width, height * 0.8, width * 0.8, height, width * 0.5, height);

    // Lower left curve.
    path.cubicTo(
        width * 0.2, height, 0, height * 0.8, width * 0.15, height * 0.6);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
