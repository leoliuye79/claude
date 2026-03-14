import { useEffect } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { useStore } from '@/store';
import OnboardingPage from '@/pages/OnboardingPage';
import MainLayout from '@/pages/MainLayout';
import ConversationsPage from '@/pages/ConversationsPage';
import ContactsPage from '@/pages/ContactsPage';
import DiscoverPage from '@/pages/DiscoverPage';
import SettingsPage from '@/pages/SettingsPage';
import ChatPage from '@/pages/ChatPage';
import AgentDetailPage from '@/pages/AgentDetailPage';
import AIModelSettingsPage from '@/pages/AIModelSettingsPage';
import CustomAgentPage from '@/pages/CustomAgentPage';

export default function App() {
  const onboardingDone = useStore((s) => s.onboardingDone);
  const darkMode = useStore((s) => s.darkMode);

  useEffect(() => {
    document.documentElement.classList.toggle('dark', darkMode);
  }, [darkMode]);

  if (!onboardingDone) {
    return (
      <BrowserRouter basename="/claude">
        <OnboardingPage />
      </BrowserRouter>
    );
  }

  return (
    <BrowserRouter basename="/claude">
      <Routes>
        <Route element={<MainLayout />}>
          <Route path="/" element={<ConversationsPage />} />
          <Route path="/contacts" element={<ContactsPage />} />
          <Route path="/discover" element={<DiscoverPage />} />
          <Route path="/settings" element={<SettingsPage />} />
        </Route>
        <Route path="/chat/:conversationId" element={<ChatPage />} />
        <Route path="/agent/:agentId" element={<AgentDetailPage />} />
        <Route path="/settings/ai-model" element={<AIModelSettingsPage />} />
        <Route path="/custom-agent" element={<CustomAgentPage />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  );
}
