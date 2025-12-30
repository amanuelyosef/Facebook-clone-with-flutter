import 'dart:convert';
import 'package:facebook_clone/features/home/presentation/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/login_screen.dart';
import 'friends_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const route = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;
  List<_Post> _posts = [];
  List<_Story> _stories = [];
  bool _isLoading = true;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedTabIndex);
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadPosts(), _loadStories()]);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPosts() async {
    try {
      // Fetch users from JSONPlaceholder
      final usersResponse = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/users'),
      );
      final List<dynamic> users = json.decode(usersResponse.body);

      // Create posts with images from Lorem Picsum
      final posts = <_Post>[];
      final messages = [
        'Just had an amazing day! The weather is perfect for outdoor activities. Who else is enjoying the sunshine? ☀️',
        'Exploring new places and making memories. Life is beautiful when you take time to appreciate the little things.',
        'Working on some exciting projects. Can\'t wait to share more details soon! Stay tuned 🚀',
        'Coffee and coding - the perfect combination for a productive morning ☕💻',
        'Throwback to this beautiful sunset. Nature never fails to amaze me 🌅',
        'Just finished reading an amazing book. Highly recommend "The Psychology of Money" to everyone!',
        'Family time is the best time. Grateful for these moments together ❤️',
        'New recipe alert! Made homemade pasta from scratch and it turned out amazing 🍝',
        'Fitness journey update: 30 days in and feeling stronger than ever 💪',
        'Weekend vibes! Who\'s ready for some fun? 🎉',
      ];

      for (int i = 0; i < 10; i++) {
        final user = users[i % users.length];
        final name = user['name'] as String;
        posts.add(
          _Post(
            author: name,
            initials: name.split(' ').map((n) => n[0]).take(2).join(),
            time: '${(i + 1)} h',
            privacy: i % 2 == 0 ? 'Public' : 'Friends',
            message: messages[i],
            imageUrl: 'https://picsum.photos/seed/${i + 100}/800/600',
            avatarUrl: 'https://i.pravatar.cc/150?u=${user['email']}',
            likes: (i + 1) * 23 + 17,
            comments: (i + 1) * 5 + 3,
            shares: (i + 1) * 2,
          ),
        );
      }

      if (mounted) {
        setState(() => _posts = posts);
      }
    } catch (e) {
      // Fallback to demo posts if API fails
      if (mounted) {
        setState(() => _posts = _fallbackPosts);
      }
    }
  }

  Future<void> _loadStories() async {
    try {
      final usersResponse = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/users?_limit=8'),
      );
      final List<dynamic> users = json.decode(usersResponse.body);

      final stories = <_Story>[
        const _Story(
          name: 'Create Story',
          avatarUrl: null,
          storyImageUrl: null,
          isCreateStory: true,
        ),
      ];

      for (int i = 0; i < users.length; i++) {
        final user = users[i];
        stories.add(
          _Story(
            name: (user['name'] as String).split(' ').first,
            avatarUrl: 'https://i.pravatar.cc/150?u=${user['email']}',
            storyImageUrl: 'https://picsum.photos/seed/${i + 200}/400/700',
            isCreateStory: false,
          ),
        );
      }

      if (mounted) {
        setState(() => _stories = stories);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _stories = _fallbackStories);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userName = currentUser?.displayName ?? 'User';
    final userPhoto = currentUser?.photoURL;
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    void onTabSelected(int index) {
      if (index == _selectedTabIndex) return;
      setState(() => _selectedTabIndex = index);
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _FacebookHeader(onSignOut: () => _handleSignOut(context)),
            _NavigationTabs(
              selectedIndex: _selectedTabIndex,
              onTabSelected: onTabSelected,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) =>
                    setState(() => _selectedTabIndex = index),
                children: [
                  _buildFeedPage(userName, userPhoto, userInitial),
                  FriendsPage(),
                  const _PlaceholderPage(title: 'Videos'),
                  const _PlaceholderPage(title: 'Marketplace'),
                  _NotificationsPage(notifications: _notifications),
                  const _PlaceholderPage(title: 'Menu'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedPage(
    String userName,
    String? userPhoto,
    String userInitial,
  ) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.facebookBlue),
      );
    }

    return RefreshIndicator(
      color: AppColors.facebookBlue,
      onRefresh: () async {
        setState(() => _isLoading = true);
        await _loadData();
      },
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Composer(
            userName: userName,
            userPhoto: userPhoto,
            userInitial: userInitial,
          ),
          const _SectionSpacer(),
          _StoriesStrip(
            stories: _stories,
            userPhoto: userPhoto,
            userInitial: userInitial,
          ),
          const _SectionSpacer(),
          _CreateRoomSection(),
          const _SectionSpacer(),
          ..._posts.map((post) => _PostCard(post: post)),
        ],
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context) async {
    if (!kIsWeb) {
      await GoogleSignIn().signOut();
    }
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}

class _FacebookHeader extends StatelessWidget {
  const _FacebookHeader({required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Text(
            'facebook',
            style: TextStyle(
              color: AppColors.facebookBlue,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -1.2,
            ),
          ),
          const Spacer(),
          _HeaderIconButton(icon: Icons.add, onTap: () {}),
          const SizedBox(width: 8),
          _HeaderIconButton(icon: Icons.search, onTap: () {}),
          const SizedBox(width: 8),
          _HeaderIconButton(
            icon: Icons.chat_bubble,
            onTap: () {},
            showBadge: true,
            badgeCount: 3,
          ),
          const SizedBox(width: 8),
          _HeaderIconButton(icon: Icons.logout, onTap: onSignOut),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.showBadge = false,
    this.badgeCount = 0,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool showBadge;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lightGray,
            ),
            child: Icon(icon, size: 20, color: AppColors.darkText),
          ),
          if (showBadge && badgeCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavigationTabs extends StatelessWidget {
  const _NavigationTabs({
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          _NavTab(
            icon: Icons.home,
            isSelected: selectedIndex == 0,
            onTap: () => onTabSelected(0),
          ),
          _NavTab(
            icon: Icons.people_outline,
            isSelected: selectedIndex == 1,
            onTap: () => onTabSelected(1),
          ),
          _NavTab(
            icon: Icons.ondemand_video,
            isSelected: selectedIndex == 2,
            onTap: () => onTabSelected(2),
          ),
          _NavTab(
            icon: Icons.storefront_outlined,
            isSelected: selectedIndex == 3,
            onTap: () => onTabSelected(3),
          ),
          _NavTab(
            icon: Icons.notifications_outlined,
            isSelected: selectedIndex == 4,
            onTap: () => onTabSelected(4),
            showBadge: true,
          ),
          _NavTab(
            icon: Icons.menu,
            isSelected: selectedIndex == 5,
            onTap: () => onTabSelected(5),
          ),
        ],
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.showBadge = false,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.facebookBlue : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                icon,
                size: 26,
                color: isSelected
                    ? AppColors.facebookBlue
                    : AppColors.textSecondary,
              ),
              if (showBadge)
                Positioned(
                  right: 16,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}


class _NotificationsPage extends StatefulWidget {
  const _NotificationsPage({required this.notifications});

  final List<_NotificationItem> notifications;

  @override
  State<_NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<_NotificationsPage> {
  String _filter = 'all';
  late List<_NotificationItem> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.notifications.toList();
  }

  void _markAllRead() {
    setState(() {
      _items = _items
          .map((item) => item.isUnread ? item.copyWith(isUnread: false) : item)
          .toList();
    });
  }

  void _markRead(int index) {
    if (!_items[index].isUnread) return;
    setState(() {
      _items[index] = _items[index].copyWith(isUnread: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredEntries = _items
        .asMap()
        .entries
        .where(
          (entry) => _filter == 'unread' ? entry.value.isUnread : true,
        )
        .toList();

    return Container(
      color: AppColors.surface,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Row(
            children: [
              const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _markAllRead,
                icon: const Icon(Icons.done_all, color: AppColors.darkText),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search, color: AppColors.darkText),
              ),
              IconButton(
                onPressed: () {},
                icon:
                    const Icon(Icons.settings_outlined, color: AppColors.darkText),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _filter == 'all',
                onSelected: (_) => setState(() => _filter = 'all'),
                selectedColor: AppColors.facebookBlue.withOpacity(0.14),
                labelStyle: TextStyle(
                  color: _filter == 'all'
                      ? AppColors.facebookBlue
                      : AppColors.darkText,
                  fontWeight: FontWeight.w700,
                ),
                backgroundColor: Colors.white,
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Unread'),
                selected: _filter == 'unread',
                onSelected: (_) => setState(() => _filter = 'unread'),
                selectedColor: AppColors.facebookBlue.withOpacity(0.14),
                labelStyle: TextStyle(
                  color: _filter == 'unread'
                      ? AppColors.facebookBlue
                      : AppColors.darkText,
                  fontWeight: FontWeight.w700,
                ),
                backgroundColor: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (filteredEntries.isEmpty)
            const EmptyState(label: 'No notifications to show')
          else
            ...filteredEntries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _NotificationCard(
                  item: entry.value,
                  onOpen: () => _markRead(entry.key),
                ),
              ),
            ),
        ],
      ),
    );
  }
}


class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, required this.onOpen});

  final _NotificationItem item;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.isUnread
          ? AppColors.facebookBlue.withOpacity(0.06)
          : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.iconBackground,
                ),
                child: Icon(item.icon, color: AppColors.facebookBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          item.timeAgo,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (item.isUnread) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.facebookBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.more_horiz,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.settings_input_component,
                size: 46, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              '$title coming soon',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
  const _Composer({
    required this.userName,
    required this.userPhoto,
    required this.userInitial,
  });

  final String userName;
  final String? userPhoto;
  final String userInitial;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              _UserAvatar(photoUrl: userPhoto, initial: userInitial, size: 40, showStoryRing: false,),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Open post composer
                  },
                  child: Container(
                    height: 40,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.lightGray),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text(
                      "What's on your mind?",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.lightGray),
          const SizedBox(height: 8),
          const Row(
            children: [
              Expanded(
                child: _ComposerAction(
                  icon: Icons.videocam,
                  label: 'Live video',
                  color: Color(0xFFF3425F),
                ),
              ),
              _VerticalDivider(),
              Expanded(
                child: _ComposerAction(
                  icon: Icons.photo_library,
                  label: 'Photo/video',
                  color: Color(0xFF45BD62),
                ),
              ),
              _VerticalDivider(),
              Expanded(
                child: _ComposerAction(
                  icon: Icons.emoji_emotions_outlined,
                  label: 'Feeling',
                  color: Color(0xFFF7B928),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({
    required this.photoUrl,
    required this.initial,
    this.size = 40,
    this.showStoryRing = false,
  });

  final String? photoUrl;
  final String initial;
  final double size;
  final bool showStoryRing;

  @override
  Widget build(BuildContext context) {
    final avatar = photoUrl != null
        ? CircleAvatar(
            radius: size / 2,
            backgroundImage: NetworkImage(photoUrl!),
            backgroundColor: AppColors.lightGray,
          )
        : CircleAvatar(
            radius: size / 2,
            backgroundColor: AppColors.facebookBlue,
            child: Text(
              initial,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: size * 0.4,
              ),
            ),
          );

    if (!showStoryRing) return avatar;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.facebookBlue, width: 2),
      ),
      child: avatar,
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 24, color: AppColors.lightGray);
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StoriesStrip extends StatelessWidget {
  const _StoriesStrip({
    required this.stories,
    required this.userPhoto,
    required this.userInitial,
  });

  final List<_Story> stories;
  final String? userPhoto;
  final String userInitial;

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 200,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final story = stories[index];
          if (story.isCreateStory) {
            return _CreateStoryCard(
              userPhoto: userPhoto,
              userInitial: userInitial,
            );
          }
          return _StoryCard(story: story);
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: stories.length,
      ),
    );
  }
}

class _CreateStoryCard extends StatelessWidget {
  const _CreateStoryCard({required this.userPhoto, required this.userInitial});

  final String? userPhoto;
  final String userInitial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: userPhoto != null
                  ? Image.network(
                      userPhoto!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : Container(
                      color: AppColors.facebookBlue.withOpacity(0.1),
                      child: Center(
                        child: Text(
                          userInitial,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.facebookBlue,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  transform: Matrix4.translationValues(0, -15, 0),
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.facebookBlue,
                    child: Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
                const Text(
                  'Create story',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
              ],
            ),
          ),
        ],
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
        borderRadius: BorderRadius.circular(12),
        image: story.storyImageUrl != null
            ? DecorationImage(
                image: NetworkImage(story.storyImageUrl!),
                fit: BoxFit.cover,
              )
            : null,
        color: story.storyImageUrl == null ? AppColors.facebookBlue : null,
      ),
      child: Stack(
        children: [
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
              ),
            ),
          ),
          // Avatar with blue ring
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.facebookBlue, width: 3),
              ),
              child: story.avatarUrl != null
                  ? CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(story.avatarUrl!),
                    )
                  : const CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.facebookBlue,
                    ),
            ),
          ),
          // Name at bottom
          Positioned(
            left: 8,
            right: 8,
            bottom: 10,
            child: Text(
              story.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.1,
                shadows: [Shadow(color: Colors.black54, blurRadius: 3)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateRoomSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.facebookBlue),
              ),
              child: const Row(
                children: [
                  Icon(Icons.video_call, color: Color(0xFFE040FB), size: 22),
                  SizedBox(width: 6),
                  Text(
                    'Create room',
                    style: TextStyle(
                      color: AppColors.facebookBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ..._onlineFriends.map(
              (friend) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(friend.avatarUrl),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF31A24C),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCard extends StatefulWidget {
  const _PostCard({required this.post});

  final _Post post;

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _isLiked = false;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likes;
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                widget.post.avatarUrl != null
                    ? CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(widget.post.avatarUrl!),
                      )
                    : CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.facebookBlue,
                        child: Text(
                          widget.post.initials,
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
                        widget.post.author,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            widget.post.time,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const Text(
                            ' · ',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Icon(
                            widget.post.privacy == 'Public'
                                ? Icons.public
                                : Icons.people,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  color: AppColors.textSecondary,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // Post Content
          if (widget.post.message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                widget.post.message,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
            ),
          const SizedBox(height: 10),
          // Post Image
          if (widget.post.imageUrl != null)
            Image.network(
              widget.post.imageUrl!,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 300,
                  color: AppColors.lightGray,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.facebookBlue,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                height: 300,
                color: AppColors.lightGray,
                child: const Icon(
                  Icons.image_not_supported,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          // Reactions count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.facebookBlue,
                  ),
                  child: const Icon(
                    Icons.thumb_up,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 2),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$_likeCount',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.post.comments} comments',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${widget.post.shares} shares',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.lightGray),
          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: _PostActionButton(
                    icon: _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    label: 'Like',
                    color: _isLiked
                        ? AppColors.facebookBlue
                        : AppColors.textSecondary,
                    onTap: _toggleLike,
                  ),
                ),
                Expanded(
                  child: _PostActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: 'Comment',
                    onTap: () {},
                  ),
                ),
                Expanded(
                  child: _PostActionButton(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostActionButton extends StatelessWidget {
  const _PostActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.textSecondary,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Data Models
class _Story {
  const _Story({
    required this.name,
    this.avatarUrl,
    this.storyImageUrl,
    this.isCreateStory = false,
  });

  final String name;
  final String? avatarUrl;
  final String? storyImageUrl;
  final bool isCreateStory;
}

class _Post {
  const _Post({
    required this.author,
    required this.initials,
    required this.time,
    required this.privacy,
    required this.message,
    this.imageUrl,
    this.avatarUrl,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
  });

  final String author;
  final String initials;
  final String time;
  final String privacy;
  final String message;
  final String? imageUrl;
  final String? avatarUrl;
  final int likes;
  final int comments;
  final int shares;
}

class _OnlineFriend {
  const _OnlineFriend({required this.avatarUrl});
  final String avatarUrl;
}

class _NotificationItem {
  const _NotificationItem({
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.icon,
    required this.iconBackground,
    this.isUnread = true,
  });

  final String title;
  final String subtitle;
  final String timeAgo;
  final IconData icon;
  final Color iconBackground;
  final bool isUnread;

  _NotificationItem copyWith({bool? isUnread}) {
    return _NotificationItem(
      title: title,
      subtitle: subtitle,
      timeAgo: timeAgo,
      icon: icon,
      iconBackground: iconBackground,
      isUnread: isUnread ?? this.isUnread,
    );
  }
}


const _notifications = <_NotificationItem>[
  _NotificationItem(
    title: 'Maya accepted your friend request',
    subtitle: 'You can now see each other’s posts and stories.',
    timeAgo: '2m',
    icon: Icons.person_add_alt,
    iconBackground: Color(0xFFE8F3FF),
    isUnread: true,
  ),
  _NotificationItem(
    title: 'New comment on your post',
    subtitle: 'Alyssa: “This looks awesome, thanks for sharing!”',
    timeAgo: '18m',
    icon: Icons.chat_bubble_outline,
    iconBackground: Color(0xFFEAF5FF),
    isUnread: true,
  ),
  _NotificationItem(
    title: 'Event reminder',
    subtitle: 'Product design meetup starts in 1 hour.',
    timeAgo: '1h',
    icon: Icons.event,
    iconBackground: Color(0xFFE9F7F1),
    isUnread: false,
  ),
  _NotificationItem(
    title: 'Page you follow posted',
    subtitle: 'Flutter Weekly just shared a new article.',
    timeAgo: '3h',
    icon: Icons.feed_outlined,
    iconBackground: Color(0xFFF6F0FF),
    isUnread: true,
  ),
  _NotificationItem(
    title: 'Marketplace update',
    subtitle: 'A laptop you saved dropped in price.',
    timeAgo: '7h',
    icon: Icons.storefront_outlined,
    iconBackground: Color(0xFFFFF3E8),
    isUnread: false,
  ),
  _NotificationItem(
    title: 'Security alert',
    subtitle: 'New login from Chrome on Windows.',
    timeAgo: '1d',
    icon: Icons.shield_outlined,
    iconBackground: Color(0xFFE8F0FF),
    isUnread: false,
  ),
];

// Fallback data
const _fallbackStories = <_Story>[
  _Story(name: 'Create Story', isCreateStory: true),
  _Story(
    name: 'Alyssa',
    avatarUrl: 'https://i.pravatar.cc/150?u=alyssa',
    storyImageUrl: 'https://picsum.photos/seed/story1/400/700',
  ),
  _Story(
    name: 'Michael',
    avatarUrl: 'https://i.pravatar.cc/150?u=michael',
    storyImageUrl: 'https://picsum.photos/seed/story2/400/700',
  ),
  _Story(
    name: 'Priya',
    avatarUrl: 'https://i.pravatar.cc/150?u=priya',
    storyImageUrl: 'https://picsum.photos/seed/story3/400/700',
  ),
  _Story(
    name: 'Jordan',
    avatarUrl: 'https://i.pravatar.cc/150?u=jordan',
    storyImageUrl: 'https://picsum.photos/seed/story4/400/700',
  ),
];

const _fallbackPosts = <_Post>[
  _Post(
    author: 'Facebook Team',
    initials: 'FT',
    time: '2 h',
    privacy: 'Public',
    message:
        'Welcome to the Facebook clone! This is built with Flutter and looks just like the real thing. 🚀',
    imageUrl: 'https://picsum.photos/seed/fb1/800/600',
    avatarUrl: 'https://i.pravatar.cc/150?u=facebook',
    likes: 234,
    comments: 45,
    shares: 12,
  ),
  _Post(
    author: 'Alyssa Chen',
    initials: 'AC',
    time: '4 h',
    privacy: 'Friends',
    message: 'Beautiful sunset today! 🌅 Nature never fails to amaze me.',
    imageUrl: 'https://picsum.photos/seed/sunset/800/600',
    avatarUrl: 'https://i.pravatar.cc/150?u=alyssa',
    likes: 156,
    comments: 23,
    shares: 5,
  ),
];

const _onlineFriends = <_OnlineFriend>[
  _OnlineFriend(avatarUrl: 'https://i.pravatar.cc/150?u=friend1'),
  _OnlineFriend(avatarUrl: 'https://i.pravatar.cc/150?u=friend2'),
  _OnlineFriend(avatarUrl: 'https://i.pravatar.cc/150?u=friend3'),
  _OnlineFriend(avatarUrl: 'https://i.pravatar.cc/150?u=friend4'),
  _OnlineFriend(avatarUrl: 'https://i.pravatar.cc/150?u=friend5'),
  _OnlineFriend(avatarUrl: 'https://i.pravatar.cc/150?u=friend6'),
];
