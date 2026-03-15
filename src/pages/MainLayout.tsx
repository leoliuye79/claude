import { Outlet, useNavigate, useLocation } from 'react-router-dom';
import { MessageCircle, Users, Compass, Settings } from 'lucide-react';

const TABS = [
  { path: '/', icon: MessageCircle, label: '对话' },
  { path: '/contacts', icon: Users, label: '伙伴' },
  { path: '/discover', icon: Compass, label: '发现' },
  { path: '/settings', icon: Settings, label: '设置' },
];

export default function MainLayout() {
  const navigate = useNavigate();
  const location = useLocation();

  return (
    <div className="flex-1 flex flex-col h-dvh bg-white dark:bg-dark-surface dark:text-gray-100">
      <div className="flex-1 flex flex-col overflow-hidden">
        <Outlet />
      </div>
      <nav className="flex items-center border-t border-gray-100/80 dark:border-dark-border/50 bg-white/90 dark:bg-dark-surface/90 glass shrink-0 px-4 pb-[env(safe-area-inset-bottom)]">
        {TABS.map((tab) => {
          const isActive = location.pathname === tab.path;
          const Icon = tab.icon;
          return (
            <button
              key={tab.path}
              onClick={() => navigate(tab.path)}
              className={`flex-1 flex flex-col items-center pt-3 pb-2.5 gap-1.5 transition-all duration-200 relative ${
                isActive ? 'text-primary' : 'text-gray-400 dark:text-gray-500'
              }`}
            >
              {isActive && (
                <div className="absolute top-0 left-1/2 -translate-x-1/2 w-6 h-0.5 rounded-full bg-primary" />
              )}
              <Icon size={22} strokeWidth={isActive ? 2.2 : 1.8} />
              <span className={`text-xs ${isActive ? 'font-semibold' : 'font-medium'}`}>{tab.label}</span>
            </button>
          );
        })}
      </nav>
    </div>
  );
}
