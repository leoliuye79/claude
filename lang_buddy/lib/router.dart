import 'package:go_router/go_router.dart';
import 'domain/entities/agent.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/conversations/conversations_screen.dart';
import 'presentation/screens/contacts/contacts_screen.dart';
import 'presentation/screens/contacts/agent_detail_screen.dart';
import 'presentation/screens/contacts/custom_agent_screen.dart';
import 'presentation/screens/chat/chat_screen.dart';
import 'presentation/screens/discover/discover_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/settings/ai_model_settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/conversations',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/conversations',
              builder: (context, state) => const ConversationsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/contacts',
              builder: (context, state) => const ContactsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/discover',
              builder: (context, state) => const DiscoverScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/chat/:conversationId',
      builder: (context, state) {
        final agent = state.extra as Agent;
        return ChatScreen(
          conversationId: state.pathParameters['conversationId']!,
          agent: agent,
        );
      },
    ),
    GoRoute(
      path: '/agent/:agentId',
      builder: (context, state) {
        final agent = state.extra as Agent;
        return AgentDetailScreen(agent: agent);
      },
    ),
    GoRoute(
      path: '/settings/ai-model',
      builder: (context, state) => const AIModelSettingsScreen(),
    ),
    GoRoute(
      path: '/settings/custom-agent',
      builder: (context, state) => const CustomAgentScreen(),
    ),
  ],
);
