import 'package:capsaul/backend/database/profile_entity.dart';
import 'package:capsaul/backend/database/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AboutYouScreen extends StatelessWidget {
  const AboutYouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About You'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ProfileProvider>().resetProfile(),
          ),
        ],
      ),
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
        _buildSection('Core Identity', Text(profile.core)),
        _buildListSection('Hobbies', profile.hobbies),
        _buildListSection('Interests', profile.interests),
        _buildListSection('Habits', profile.habits),
        _buildSection('Work & Skills', _buildWorkSection()),
        _buildListSection('Skills', profile.skills),
        _buildSection('Lifestyle', Text(profile.lifestyle)),
        _buildSection('Learnings', Text(profile.learnings)),
        _buildSection('Other Insights', Text(profile.others)),
        _buildCategoryCloud(),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Text(
            profile.emoji,
            style: const TextStyle(fontSize: 64),
          ),
          Text(
            'Last Updated: ${DateFormat.yMMMd().format(profile.lastUpdated)}',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverToBoxAdapter(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                content,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (profile.work.isNotEmpty) Text(profile.work),
        if (profile.skills.isNotEmpty)
          Wrap(
            spacing: 8,
            children: profile.skills
                .map((skill) => Chip(label: Text(skill)))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildListSection(String title, List<String> items) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverToBoxAdapter(
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

  Widget _buildCategoryCloud() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverToBoxAdapter(
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          children: profile.categories
              .map((category) => ActionChip(
                    label: Text(category),
                    onPressed: () {},
                    avatar: const Icon(Icons.category, size: 16),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
