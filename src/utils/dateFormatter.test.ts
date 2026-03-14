import { describe, it, expect, vi, afterEach } from 'vitest';
import { formatChatTime, formatConversationTime } from './dateFormatter';

describe('dateFormatter', () => {
  afterEach(() => {
    vi.useRealTimers();
  });

  describe('formatChatTime', () => {
    it('should show time only for today', () => {
      const now = new Date();
      now.setHours(14, 30, 0, 0);
      vi.setSystemTime(now);

      const result = formatChatTime(now.toISOString());
      expect(result).toBe('14:30');
    });

    it('should show "昨天" for yesterday', () => {
      vi.setSystemTime(new Date('2024-06-15T10:00:00'));
      const yesterday = new Date('2024-06-14T09:15:00');
      const result = formatChatTime(yesterday.toISOString());
      expect(result).toBe('昨天 09:15');
    });

    it('should show weekday for dates within 6 days', () => {
      vi.setSystemTime(new Date('2024-06-15T10:00:00')); // Saturday
      const threeDaysAgo = new Date('2024-06-12T08:00:00'); // Wednesday
      const result = formatChatTime(threeDaysAgo.toISOString());
      expect(result).toBe('周三 08:00');
    });

    it('should show MM/DD for older dates', () => {
      vi.setSystemTime(new Date('2024-06-15T10:00:00'));
      const oldDate = new Date('2024-05-01T14:00:00');
      const result = formatChatTime(oldDate.toISOString());
      expect(result).toBe('05/01 14:00');
    });
  });

  describe('formatConversationTime', () => {
    it('should show time for today', () => {
      const now = new Date();
      now.setHours(9, 5, 0, 0);
      vi.setSystemTime(now);

      const result = formatConversationTime(now.toISOString());
      expect(result).toBe('09:05');
    });

    it('should show "昨天" for yesterday', () => {
      vi.setSystemTime(new Date('2024-06-15T10:00:00'));
      const yesterday = new Date('2024-06-14T09:15:00');
      const result = formatConversationTime(yesterday.toISOString());
      expect(result).toBe('昨天');
    });

    it('should show weekday within 6 days', () => {
      vi.setSystemTime(new Date('2024-06-15T10:00:00')); // Saturday
      const date = new Date('2024-06-12T08:00:00'); // Wednesday
      const result = formatConversationTime(date.toISOString());
      expect(result).toBe('周三');
    });

    it('should show MM/DD for older dates', () => {
      vi.setSystemTime(new Date('2024-06-15T10:00:00'));
      const oldDate = new Date('2024-01-15T14:00:00');
      const result = formatConversationTime(oldDate.toISOString());
      expect(result).toBe('01/15');
    });
  });
});
