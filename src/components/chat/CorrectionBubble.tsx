import type { Correction } from '@/types';
import { Pencil, ArrowRight } from 'lucide-react';

interface Props {
  correction: Correction;
}

export default function CorrectionBubble({ correction }: Props) {
  return (
    <div className="max-w-[85%] mt-2 bg-gradient-to-br from-primary/5 to-primary-light/10 dark:from-primary/10 dark:to-primary-light/5 border border-primary/20 dark:border-primary/15 rounded-2xl p-4 animate-fade-in">
      <div className="flex items-center gap-2 mb-3">
        <div className="w-6 h-6 rounded-lg bg-primary/15 flex items-center justify-center">
          <Pencil size={12} className="text-primary dark:text-primary-light" />
        </div>
        <span className="text-[13px] font-semibold text-primary-dark dark:text-primary-light">语法纠正</span>
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
