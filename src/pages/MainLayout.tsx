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
    <div className="flex-1 flex flex-col h-dvh">
      <div className="flex-1 flex flex-col overflow-hidden">
        <Outlet />
      </div>
      <nav className="flex items-center border-t border-gray-100 bg-white shrink-0">
        {TABS.map((tab) => {
          const isActive = location.pathname === tab.path;
          const Icon = tab.icon;
          return (
            <button
              key={tab.path}
              onClick={() => navigate(tab.path)}
              className={`flex-1 flex flex-col items-center py-2 gap-0.5 transition-colors ${
                isActive ? 'text-primary' : 'text-gray-400'
              }`}
            >
              <Icon size={22} />
              <span className="text-[10px]">{tab.label}</span>
            </button>
          );
        })}
      </nav>
    </div>
  );
}
