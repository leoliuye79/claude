const WEEKDAYS = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];

function pad(n: number): string {
  return n.toString().padStart(2, '0');
}

function isSameDay(a: Date, b: Date): boolean {
  return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
}

function daysBetween(a: Date, b: Date): number {
  const msPerDay = 86400000;
  const da = new Date(a.getFullYear(), a.getMonth(), a.getDate());
  const db = new Date(b.getFullYear(), b.getMonth(), b.getDate());
  return Math.round((db.getTime() - da.getTime()) / msPerDay);
}

export function formatChatTime(dateStr: string): string {
  const date = new Date(dateStr);
  const now = new Date();
  const time = `${pad(date.getHours())}:${pad(date.getMinutes())}`;

  if (isSameDay(date, now)) return time;

  const diff = daysBetween(date, now);
  if (diff === 1) return `昨天 ${time}`;
  if (diff <= 6) return `${WEEKDAYS[date.getDay()]} ${time}`;
  return `${pad(date.getMonth() + 1)}/${pad(date.getDate())} ${time}`;
}

export function formatConversationTime(dateStr: string): string {
  const date = new Date(dateStr);
  const now = new Date();

  if (isSameDay(date, now)) return `${pad(date.getHours())}:${pad(date.getMinutes())}`;

  const diff = daysBetween(date, now);
  if (diff === 1) return '昨天';
  if (diff <= 6) return WEEKDAYS[date.getDay()];
  return `${pad(date.getMonth() + 1)}/${pad(date.getDate())}`;
}
