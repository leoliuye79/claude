import type { Correction } from '@/types';
import { Pencil, ArrowRight } from 'lucide-react';

interface Props {
  correction: Correction;
}

export default function CorrectionBubble({ correction }: Props) {
  return (
    <div className="max-w-[85%] mt-2 bg-gradient-to-br from-amber-50 to-orange-50 dark:from-amber-950/30 dark:to-orange-950/20 border border-amber-200/60 dark:border-amber-800/30 rounded-2xl p-4 animate-fade-in">
      <div className="flex items-center gap-2 mb-3">
        <div className="w-6 h-6 rounded-lg bg-amber-400/20 flex items-center justify-center">
          <Pencil size={12} className="text-amber-600 dark:text-amber-400" />
        </div>
        <span className="text-[13px] font-semibold text-amber-700 dark:text-amber-400">语法纠正</span>
      </div>
      {correction.details.map((d, i) => (
        <div key={i} className="mb-3 last:mb-0">
          <div className="flex items-center gap-2 text-[13px] mb-1.5">
            <span className="text-danger line-through font-medium">{d.incorrect}</span>
            <ArrowRight size={12} className="text-gray-400 shrink-0" />
            <span className="text-success font-semibold">{d.correct}</span>
          </div>
          <p className="text-[12px] text-gray-600 dark:text-gray-400 leading-relaxed">{d.explanationZh}</p>
          {d.example && (
            <p className="text-[12px] text-gray-400 dark:text-gray-500 mt-1 italic leading-relaxed">
              e.g. {d.example}
            </p>
          )}
        </div>
      ))}
    </div>
  );
}
