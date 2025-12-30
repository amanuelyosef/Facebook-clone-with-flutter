import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/empty_state.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  String _activeTab = 'requests';
  late List<_FriendRequest> _pendingRequests;
  late List<_FriendSuggestion> _pendingSuggestions;

  @override
  void initState() {
    super.initState();
    _pendingRequests = List<_FriendRequest>.of(_friendRequests);
    _pendingSuggestions = List<_FriendSuggestion>.of(_friendSuggestions);
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_activeTab == 'requests') {
      body = Column(
        key: const ValueKey('requests'),
        children: _pendingRequests.isEmpty
            ? [const EmptyState(label: 'No pending requests')]
            : _pendingRequests
                .map(
                  (req) => _FriendRequestCard(
                    request: req,
                    onConfirm: () => setState(() {
                      _pendingRequests.remove(req);
                    }),
                    onDelete: () => setState(() {
                      _pendingRequests.remove(req);
                    }),
                  ),
                )
                .toList(),
      );
    } else if (_activeTab == 'suggestions') {
      body = Column(
        key: const ValueKey('suggestions'),
        children: _pendingSuggestions.isEmpty
            ? [const EmptyState(label: 'No suggestions right now')]
            : _pendingSuggestions
                .map(
                  (sug) => _FriendSuggestionCard(
                    suggestion: sug,
                    onAdd: () => setState(() {
                      _pendingSuggestions.remove(sug);
                    }),
                    onRemove: () => setState(() {
                      _pendingSuggestions.remove(sug);
                    }),
                  ),
                )
                .toList(),
      );
    } else {
      body = _FriendsGrid(
        key: const ValueKey('all'),
        friends: _allFriends,
      );
    }

    return Container(
      color: AppColors.surface,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Row(
            children: [
              const Text(
                'Friends',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              const Spacer(),
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
          Wrap(
            spacing: 8,
            children: [
              _FriendsTabButton(
                label: 'Requests',
                isSelected: _activeTab == 'requests',
                onTap: () => setState(() => _activeTab = 'requests'),
                trailingCount: _pendingRequests.length,
              ),
              _FriendsTabButton(
                label: 'Suggestions',
                isSelected: _activeTab == 'suggestions',
                onTap: () => setState(() => _activeTab = 'suggestions'),
                trailingCount: _pendingSuggestions.length,
              ),
              _FriendsTabButton(
                label: 'Your friends',
                isSelected: _activeTab == 'all',
                onTap: () => setState(() => _activeTab = 'all'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: body,
          ),
        ],
      ),
    );
  }
}

class _FriendsTabButton extends StatelessWidget {
  const _FriendsTabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.trailingCount,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? trailingCount;

  @override
  Widget build(BuildContext context) {
    final badge = trailingCount != null && trailingCount! > 0
        ? Container(
            margin: const EdgeInsets.only(left: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.facebookBlue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              trailingCount!.toString(),
              style: const TextStyle(
                color: AppColors.facebookBlue,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          )
        : const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.facebookBlue.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color:
                isSelected ? AppColors.facebookBlue : AppColors.lightGray,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color:
                    isSelected ? AppColors.facebookBlue : AppColors.darkText,
              ),
            ),
            badge,
          ],
        ),
      ),
    );
  }
}

class _FriendRequestCard extends StatelessWidget {
  const _FriendRequestCard({
    required this.request,
    required this.onConfirm,
    required this.onDelete,
  });

  final _FriendRequest request;
  final VoidCallback onConfirm;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(request.avatarUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.people_alt_outlined,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${request.mutualFriends} mutual friends',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '· ${request.timeAgo}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.facebookBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: onConfirm,
                        child: const Text('Confirm'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.darkText,
                          side: const BorderSide(color: AppColors.lightGray),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: onDelete,
                        child: const Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendSuggestionCard extends StatelessWidget {
  const _FriendSuggestionCard({
    required this.suggestion,
    required this.onAdd,
    required this.onRemove,
  });

  final _FriendSuggestion suggestion;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(suggestion.avatarUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.people_alt_outlined,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${suggestion.mutualFriends} mutual friends',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.facebookBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: onAdd,
                        child: const Text('Add friend'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.darkText,
                          side: const BorderSide(color: AppColors.lightGray),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: onRemove,
                        child: const Text('Remove'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _Friend {
  const _Friend({
    required this.name,
    required this.avatarUrl,
    required this.mutualFriends,
    this.isOnline = false,
  });

  final String name;
  final String avatarUrl;
  final int mutualFriends;
  final bool isOnline;
}


class _FriendsGrid extends StatelessWidget {
  const _FriendsGrid({super.key, required this.friends});

  final List<_Friend> friends;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: key,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: friends.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 3 / 2,
      ),
      itemBuilder: (_, index) {
        final friend = friends[index];
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightGray),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage(friend.avatarUrl),
                  ),
                  if (friend.isOnline)
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
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      friend.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${friend.mutualFriends} mutual friends',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FriendRequest {
  const _FriendRequest({
    required this.name,
    required this.avatarUrl,
    required this.mutualFriends,
    required this.timeAgo,
  });

  final String name;
  final String avatarUrl;
  final int mutualFriends;
  final String timeAgo;
}

class _FriendSuggestion {
  const _FriendSuggestion({
    required this.name,
    required this.avatarUrl,
    required this.mutualFriends,
  });

  final String name;
  final String avatarUrl;
  final int mutualFriends;
}

const _friendRequests = <_FriendRequest>[
  _FriendRequest(
    name: 'Maya Patel',
    avatarUrl: 'https://i.pravatar.cc/150?u=freq1',
    mutualFriends: 8,
    timeAgo: '2 h',
  ),
  _FriendRequest(
    name: 'Lucas Martinez',
    avatarUrl: 'https://i.pravatar.cc/150?u=freq2',
    mutualFriends: 4,
    timeAgo: '4 h',
  ),
  _FriendRequest(
    name: 'Alicia Walker',
    avatarUrl: 'https://i.pravatar.cc/150?u=freq3',
    mutualFriends: 12,
    timeAgo: '1 d',
  ),
];

const _friendSuggestions = <_FriendSuggestion>[
  _FriendSuggestion(
    name: 'Noah Kim',
    avatarUrl: 'https://i.pravatar.cc/150?u=fsug1',
    mutualFriends: 6,
  ),
  _FriendSuggestion(
    name: 'Sara Ahmed',
    avatarUrl: 'https://i.pravatar.cc/150?u=fsug2',
    mutualFriends: 3,
  ),
  _FriendSuggestion(
    name: 'Daniel Green',
    avatarUrl: 'https://i.pravatar.cc/150?u=fsug3',
    mutualFriends: 9,
  ),
  _FriendSuggestion(
    name: 'Victoria Lee',
    avatarUrl: 'https://i.pravatar.cc/150?u=fsug4',
    mutualFriends: 11,
  ),
];

const _allFriends = <_Friend>[
  _Friend(
    name: 'Priya Singh',
    avatarUrl: 'https://i.pravatar.cc/150?u=friend_a',
    mutualFriends: 18,
    isOnline: true,
  ),
  _Friend(
    name: 'Michael Chen',
    avatarUrl: 'https://i.pravatar.cc/150?u=friend_b',
    mutualFriends: 10,
    isOnline: false,
  ),
  _Friend(
    name: 'Elena Petrova',
    avatarUrl: 'https://i.pravatar.cc/150?u=friend_c',
    mutualFriends: 5,
    isOnline: true,
  ),
  _Friend(
    name: 'David Brown',
    avatarUrl: 'https://i.pravatar.cc/150?u=friend_d',
    mutualFriends: 7,
    isOnline: false,
  ),
  _Friend(
    name: 'Hannah White',
    avatarUrl: 'https://i.pravatar.cc/150?u=friend_e',
    mutualFriends: 14,
    isOnline: true,
  ),
  _Friend(
    name: 'Jonas Keller',
    avatarUrl: 'https://i.pravatar.cc/150?u=friend_f',
    mutualFriends: 6,
    isOnline: false,
  ),
];
