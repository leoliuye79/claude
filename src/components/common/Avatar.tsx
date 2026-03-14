const GRADIENTS = [
  'from-violet-500 to-purple-600',
  'from-blue-500 to-cyan-500',
  'from-emerald-500 to-teal-500',
  'from-rose-500 to-pink-500',
  'from-amber-500 to-orange-500',
  'from-indigo-500 to-blue-600',
  'from-fuchsia-500 to-pink-500',
  'from-cyan-500 to-teal-500',
];

function hashGradient(name: string): string {
  let hash = 0;
  for (let i = 0; i < name.length; i++) {
    hash = name.charCodeAt(i) + ((hash << 5) - hash);
  }
  return GRADIENTS[Math.abs(hash) % GRADIENTS.length];
}

interface AvatarProps {
  name: string;
  size?: 'sm' | 'md' | 'lg' | 'xl';
}

const SIZES = {
  sm: 'w-9 h-9 text-sm',
  md: 'w-11 h-11 text-base',
  lg: 'w-16 h-16 text-2xl',
  xl: 'w-20 h-20 text-3xl',
};

export default function Avatar({ name, size = 'md' }: AvatarProps) {
  const letter = (name[0] ?? '?').toUpperCase();
  const gradient = hashGradient(name);
  return (
    <div
      className={`${SIZES[size]} bg-gradient-to-br ${gradient} rounded-2xl flex items-center justify-center text-white font-bold shrink-0 shadow-sm`}
    >
      {letter}
    </div>
  );
}
