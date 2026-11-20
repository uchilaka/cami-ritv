/**
 * The user's theme preference, persisted per browser.
 *
 * `light` and `dark` override the operating system. `system` (the default)
 * follows `prefers-color-scheme`, including changes made while the page is open.
 * The resolved theme is expressed as the `dark` class on <html>, which is what
 * Tailwind's `darkMode: 'selector'` keys every `dark:` utility on.
 *
 * This deliberately does not use flowbite-react's useThemeMode: it defaults to
 * `light` (and writes that to storage for every visitor on mount), and its
 * `auto` mode is computed once rather than following OS changes. For the same
 * reason the old `flowbite-theme-mode` key is not migrated: its value says
 * nothing about what the user chose.
 */

export const THEME_PREFERENCES = ['light', 'dark', 'system'] as const;
export type ThemePreference = (typeof THEME_PREFERENCES)[number];
export type Theme = 'light' | 'dark';

export const STORAGE_KEY = 'theme-preference';
const DEFAULT_PREFERENCE: ThemePreference = 'system';
const DARK_SCHEME_QUERY = '(prefers-color-scheme: dark)';

const isThemePreference = (value: unknown): value is ThemePreference =>
  THEME_PREFERENCES.includes(value as ThemePreference);

export const readPreference = (): ThemePreference => {
  const stored = localStorage.getItem(STORAGE_KEY);
  return isThemePreference(stored) ? stored : DEFAULT_PREFERENCE;
};

// The browser's `storage` event only fires in *other* tabs, so same-page
// listeners (e.g. the navbar control while the account page has its own) are
// told through this event instead.
const PREFERENCE_CHANGE_EVENT = 'theme-preference-change';

export const writePreference = (preference: ThemePreference): void => {
  localStorage.setItem(STORAGE_KEY, preference);
  window.dispatchEvent(
    new CustomEvent<ThemePreference>(PREFERENCE_CHANGE_EVENT, {
      detail: preference,
    })
  );
};

/**
 * Calls `onChange` when the preference is written on this page or in another
 * tab. Returns an unsubscribe.
 */
export const subscribeToPreference = (
  onChange: (preference: ThemePreference) => void
): (() => void) => {
  const onPageChange = (event: Event) =>
    onChange((event as CustomEvent<ThemePreference>).detail);
  const onOtherTabChange = (event: StorageEvent) => {
    if (event.key === STORAGE_KEY) onChange(readPreference());
  };
  window.addEventListener(PREFERENCE_CHANGE_EVENT, onPageChange);
  window.addEventListener('storage', onOtherTabChange);
  return () => {
    window.removeEventListener(PREFERENCE_CHANGE_EVENT, onPageChange);
    window.removeEventListener('storage', onOtherTabChange);
  };
};

// window.matchMedia is optional-chained because jsdom (and some embedded
// webviews) don't implement it; without it, `system` resolves to light.
export const systemPrefersDark = (): boolean =>
  window.matchMedia?.(DARK_SCHEME_QUERY).matches ?? false;

export const resolveTheme = (
  preference: ThemePreference,
  prefersDark: boolean = systemPrefersDark()
): Theme => {
  if (preference === 'system') return prefersDark ? 'dark' : 'light';
  return preference;
};

export const applyTheme = (
  theme: Theme,
  root: HTMLElement = document.documentElement
): void => {
  root.classList.toggle('dark', theme === 'dark');
};

/** Calls `onChange` whenever the OS scheme flips. Returns an unsubscribe. */
export const subscribeToSystemTheme = (
  onChange: (prefersDark: boolean) => void
): (() => void) => {
  const query = window.matchMedia?.(DARK_SCHEME_QUERY);
  if (!query) return () => {};
  const listener = (event: { matches: boolean }) => onChange(event.matches);
  query.addEventListener('change', listener);
  return () => query.removeEventListener('change', listener);
};
