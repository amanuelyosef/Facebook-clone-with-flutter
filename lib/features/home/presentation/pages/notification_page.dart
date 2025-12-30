import 'package:facebook_clone/features/home/presentation/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class NotificationsPage extends StatefulWidget {

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String _filter = 'all';
  late List<_NotificationItem> _items;

  @override
  void initState() {
    super.initState();
    _items = _notifications.toList();
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
    title: 'Abebe accepted your friend request',
    subtitle: 'You can now see each other’s posts and stories.',
    timeAgo: '2m',
    icon: Icons.person_add_alt,
    iconBackground: Color(0xFFE8F3FF),
    isUnread: true,
  ),
  _NotificationItem(
    title: 'New comment on your post',
    subtitle: 'Abebe: “This looks awesome, thanks for sharing!”',
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
