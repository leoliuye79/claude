import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/agent_provider.dart';
import '../../providers/conversation_provider.dart';
import '../../widgets/contacts/contact_tile.dart';

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentsAsync = ref.watch(agentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.tabContacts),
        backgroundColor: AppColors.appBarDark,
      ),
      backgroundColor: AppColors.chatBackground,
      body: agentsAsync.when(
        data: (agents) {
          return ListView.separated(
            itemCount: agents.length,
            separatorBuilder: (_, __) => const Divider(indent: 76),
            itemBuilder: (context, index) {
              final agent = agents[index];
              return ContactTile(
                agent: agent,
                onTap: () async {
                  final conversationActions =
                      ref.read(conversationActionsProvider);
                  final conversation = await conversationActions
                      .getOrCreateConversation(agent.id);
                  if (context.mounted) {
                    context.push('/chat/${conversation.id}', extra: agent);
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
