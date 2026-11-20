import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import {
  STORAGE_KEY,
  applyTheme,
  readPreference,
  resolveTheme,
  subscribeToPreference,
  subscribeToSystemTheme,
  writePreference,
} from './themePreference';

type Listener = (event: { matches: boolean }) => void;

// jsdom has no matchMedia. This stub lets a test flip the OS scheme and fire
// the change event the way a browser would.
const stubSystemScheme = (initiallyDark: boolean) => {
  const listeners = new Set<Listener>();
  const query = {
    matches: initiallyDark,
    addEventListener: (_: 'change', listener: Listener) =>
      listeners.add(listener),
    removeEventListener: (_: 'change', listener: Listener) =>
      listeners.delete(listener),
  };
  vi.stubGlobal(
    'matchMedia',
    vi.fn(() => query)
  );
  return {
    setDark(dark: boolean) {
      query.matches = dark;
      listeners.forEach((listener) => listener({ matches: dark }));
    },
    listenerCount: () => listeners.size,
  };
};

describe('themePreference', () => {
  beforeEach(() => {
    localStorage.clear();
    document.documentElement.className = '';
  });

  afterEach(() => {
    vi.unstubAllGlobals();
  });

  describe('readPreference', () => {
    it('defaults to system when nothing is stored', () => {
      expect(readPreference()).toBe('system');
    });

    it.each(['light', 'dark', 'system'] as const)('returns a stored %s', (pref) => {
      localStorage.setItem(STORAGE_KEY, pref);
      expect(readPreference()).toBe(pref);
    });

    it('treats an unrecognised stored value as system', () => {
      localStorage.setItem(STORAGE_KEY, 'auto');
      expect(readPreference()).toBe('system');
    });

    it('ignores the legacy flowbite key, which was written as light for every visitor', () => {
      localStorage.setItem('flowbite-theme-mode', 'light');
      expect(readPreference()).toBe('system');
    });
  });

  describe('writePreference', () => {
    it('round-trips through readPreference', () => {
      writePreference('dark');
      expect(readPreference()).toBe('dark');
    });
  });

  describe('subscribeToPreference', () => {
    it('hears writes made elsewhere on the page', () => {
      const onChange = vi.fn();
      const unsubscribe = subscribeToPreference(onChange);
      writePreference('dark');
      expect(onChange).toHaveBeenLastCalledWith('dark');
      unsubscribe();
      writePreference('light');
      expect(onChange).toHaveBeenCalledTimes(1);
    });

    it('hears writes made in another tab', () => {
      const onChange = vi.fn();
      const unsubscribe = subscribeToPreference(onChange);
      localStorage.setItem(STORAGE_KEY, 'light');
      window.dispatchEvent(
        new StorageEvent('storage', { key: STORAGE_KEY, newValue: 'light' })
      );
      expect(onChange).toHaveBeenLastCalledWith('light');
      unsubscribe();
    });

    it('ignores other storage keys', () => {
      const onChange = vi.fn();
      const unsubscribe = subscribeToPreference(onChange);
      window.dispatchEvent(new StorageEvent('storage', { key: 'unrelated' }));
      expect(onChange).not.toHaveBeenCalled();
      unsubscribe();
    });
  });

  describe('resolveTheme', () => {
    it('lets an explicit choice override the system scheme', () => {
      expect(resolveTheme('light', true)).toBe('light');
      expect(resolveTheme('dark', false)).toBe('dark');
    });

    it('follows the system scheme for system', () => {
      expect(resolveTheme('system', true)).toBe('dark');
      expect(resolveTheme('system', false)).toBe('light');
    });
  });

  describe('applyTheme', () => {
    it('adds and removes the dark class on <html>', () => {
      applyTheme('dark');
      expect(document.documentElement.classList.contains('dark')).toBe(true);
      applyTheme('light');
      expect(document.documentElement.classList.contains('dark')).toBe(false);
    });
  });

  describe('subscribeToSystemTheme', () => {
    it('reports OS scheme changes until unsubscribed', () => {
      const system = stubSystemScheme(false);
      const onChange = vi.fn();
      const unsubscribe = subscribeToSystemTheme(onChange);

      system.setDark(true);
      expect(onChange).toHaveBeenLastCalledWith(true);

      unsubscribe();
      expect(system.listenerCount()).toBe(0);
    });
  });
});
