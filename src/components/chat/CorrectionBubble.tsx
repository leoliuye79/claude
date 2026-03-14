import type { Correction } from '@/types';

interface Props {
  correction: Correction;
}

export default function CorrectionBubble({ correction }: Props) {
  return (
    <div className="max-w-[85%] mt-2 bg-amber-50 border border-amber-200 rounded-xl p-3 text-sm">
      <div className="font-medium text-amber-700 mb-2 flex items-center gap-1">
        ✏️ 语法纠正
      </div>
      {correction.details.map((d, i) => (
        <div key={i} className="mb-2 last:mb-0">
          <div className="flex gap-2 text-xs mb-1">
            <span className="text-red-500 line-through">{d.incorrect}</span>
            <span className="text-green-600 font-medium">→ {d.correct}</span>
          </div>
          <p className="text-xs text-gray-600">{d.explanationZh}</p>
          {d.example && (
            <p className="text-xs text-gray-400 mt-0.5 italic">e.g. {d.example}</p>
          )}
        </div>
      ))}
    </div>
  );
}
