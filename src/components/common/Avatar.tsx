const COLORS = [
  'bg-red-400', 'bg-blue-400', 'bg-green-400', 'bg-purple-400',
  'bg-pink-400', 'bg-indigo-400', 'bg-teal-400', 'bg-orange-400',
];

function hashColor(name: string): string {
  let hash = 0;
  for (let i = 0; i < name.length; i++) {
    hash = name.charCodeAt(i) + ((hash << 5) - hash);
  }
  return COLORS[Math.abs(hash) % COLORS.length];
}

interface AvatarProps {
  name: string;
  size?: 'sm' | 'md' | 'lg';
}

const SIZES = { sm: 'w-8 h-8 text-sm', md: 'w-10 h-10 text-base', lg: 'w-14 h-14 text-xl' };

export default function Avatar({ name, size = 'md' }: AvatarProps) {
  const letter = (name[0] ?? '?').toUpperCase();
  return (
    <div className={`${SIZES[size]} ${hashColor(name)} rounded-full flex items-center justify-center text-white font-semibold shrink-0`}>
      {letter}
    </div>
  );
}
