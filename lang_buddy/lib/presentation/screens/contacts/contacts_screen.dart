import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/entities/agent.dart';
import '../../providers/agent_provider.dart';
import '../../providers/conversation_provider.dart';
import '../../widgets/contacts/contact_tile.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Agent> _filterAgents(List<Agent> agents) {
    if (_searchQuery.isEmpty) return agents;
    final q = _searchQuery.toLowerCase();
    return agents.where((a) {
      return a.name.toLowerCase().contains(q) ||
          a.nameZh.contains(q) ||
          a.role.label.toLowerCase().contains(q);
    }).toList();
  }

  Map<String, List<Agent>> _groupByLetter(List<Agent> agents) {
    final sorted = List<Agent>.from(agents)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final groups = <String, List<Agent>>{};
    for (final agent in sorted) {
      final letter = agent.name.isNotEmpty ? agent.name[0].toUpperCase() : '#';
      groups.putIfAbsent(letter, () => []).add(agent);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context, ) {
    final agentsAsync = ref.watch(agentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.tabContacts),
        backgroundColor: AppColors.appBarDark,
      ),
      backgroundColor: AppColors.chatBackground,
      body: Column(
        children: [
          // Search bar
          Container(
            color: AppColors.chatBackground,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: '搜索',
                hintStyle: const TextStyle(color: AppColors.textHint),
                prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textHint),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Agent list
          Expanded(
            child: agentsAsync.when(
              data: (agents) {
                final filtered = _filterAgents(agents);
                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('没有找到匹配的联系人',
                        style: TextStyle(color: AppColors.textSecondary)),
                  );
                }

                final groups = _groupByLetter(filtered);
                final letters = groups.keys.toList();

                return ListView.builder(
                  itemCount: letters.fold<int>(
                      0, (sum, l) => sum + 1 + groups[l]!.length),
                  itemBuilder: (context, index) {
                    int count = 0;
                    for (final letter in letters) {
                      if (index == count) {
                        return _buildLetterHeader(letter);
                      }
                      count++;
                      final agentsInGroup = groups[letter]!;
                      if (index < count + agentsInGroup.length) {
                        final agent = agentsInGroup[index - count];
                        return ContactTile(
                          agent: agent,
                          onTap: () async {
                            final conversationActions =
                                ref.read(conversationActionsProvider);
                            final conversation = await conversationActions
                                .getOrCreateConversation(agent.id);
                            if (context.mounted) {
                              context.push('/chat/${conversation.id}',
                                  extra: agent);
                            }
                          },
                        );
                      }
                      count += agentsInGroup.length;
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLetterHeader(String letter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: AppColors.chatBackground,
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
