import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const route = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('facebook'),
        actions: const [
          _CircleIconButton(icon: Icons.search),
          _CircleIconButton(icon: Icons.messenger_outline),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: const [
          _Composer(),
          _SectionSpacer(),
          _StoriesStrip(),
          _SectionSpacer(),
          _PostList(),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.lightGray,
        ),
        child: Icon(icon, size: 20, color: AppColors.darkText),
      ),
    );
  }
}

class _SectionSpacer extends StatelessWidget {
  const _SectionSpacer();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 8);
  }
}

class _Composer extends StatelessWidget {
  const _Composer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.facebookBlue,
                child: Text(
                  'Y',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 40,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    "What's on your mind?",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.lightGray),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _ComposerAction(icon: Icons.videocam, label: 'Live', color: Colors.redAccent),
              _VerticalDivider(),
              _ComposerAction(icon: Icons.photo_library, label: 'Photo', color: Colors.green),
              _VerticalDivider(),
              _ComposerAction(icon: Icons.location_on, label: 'Check in', color: Colors.pinkAccent),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      color: AppColors.lightGray,
    );
  }
}

class _ComposerAction extends StatelessWidget {
  const _ComposerAction({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _StoriesStrip extends StatelessWidget {
  const _StoriesStrip();

  @override
  Widget build(BuildContext context) {
    final stories = _demoStories;
    return Container(
      height: 190,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final story = stories[index];
          return _StoryCard(story: story);
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: stories.length,
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.story});

  final _Story story;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            story.accent.withOpacity(0.75),
            story.accent.withOpacity(0.35),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 10,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 15,
                backgroundColor: story.accent,
                child: Text(
                  story.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Text(
              story.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostList extends StatelessWidget {
  const _PostList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _demoPosts
          .map((post) => _PostCard(post: post))
          .toList(growable: false),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});

  final _Post post;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: post.avatarColor,
                child: Text(
                  post.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.author,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${post.time}  b7 ${post.privacy}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz, color: AppColors.textSecondary),
            ],
          ),
          if (post.message.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
                      '${post.time} - ${post.privacy}',
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ],
          const SizedBox(height: 10),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: post.imageColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              image: post.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(post.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _PostAction(icon: Icons.thumb_up_alt_outlined, label: 'Like'),
              _PostAction(icon: Icons.mode_comment_outlined, label: 'Comment'),
              _PostAction(icon: Icons.share_outlined, label: 'Share'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostAction extends StatelessWidget {
  const _PostAction({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Story {
  const _Story({
    required this.name,
    required this.initials,
    required this.accent,
  });

  final String name;
  final String initials;
  final Color accent;
}

class _Post {
  const _Post({
    required this.author,
    required this.initials,
    required this.time,
    required this.privacy,
    required this.message,
    this.imageUrl,
    required this.imageColor,
    required this.avatarColor,
  });

  final String author;
  final String initials;
  final String time;
  final String privacy;
  final String message;
  final String? imageUrl;
  final Color imageColor;
  final Color avatarColor;
}

const _demoStories = <_Story>[
  _Story(name: 'Your Story', initials: 'Y', accent: AppColors.facebookBlue),
  _Story(name: 'Alyssa', initials: 'A', accent: Colors.purple),
  _Story(name: 'Michael', initials: 'M', accent: Colors.orange),
  _Story(name: 'Priya', initials: 'P', accent: Colors.teal),
  _Story(name: 'Jordan', initials: 'J', accent: Colors.redAccent),
];

const _demoPosts = <_Post>[
  _Post(
    author: 'Facebook Team',
    initials: 'F',
    time: '2 h',
    privacy: 'Public',
    message: 'Recreating the Facebook experience with Flutter. Tap around to explore the layout.',
    imageUrl: null,
    imageColor: AppColors.facebookBlue,
    avatarColor: AppColors.facebookBlue,
  ),
  _Post(
    author: 'Alyssa Chen',
    initials: 'A',
    time: '4 h',
    privacy: 'Friends',
    message: 'Weekend vibes and coffee runs. Flutter makes building UIs fun!',
    imageUrl: null,
    imageColor: Colors.orange,
    avatarColor: Colors.purple,
  ),
  _Post(
    author: 'Michael Scott',
    initials: 'M',
    time: '8 h',
    privacy: 'Friends',
    message: 'Just shipped the splash screen animation for this clone. Looks close to the real thing.',
    imageUrl: null,
    imageColor: Colors.green,
    avatarColor: Colors.teal,
  ),
];
