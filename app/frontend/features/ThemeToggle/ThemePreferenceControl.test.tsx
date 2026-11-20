import React, { act } from 'react';
import { createRoot, Root } from 'react-dom/client';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import ThemePreferenceControl from './ThemePreferenceControl';
import { STORAGE_KEY } from './themePreference';

// Tells React 19 that act() is in use, so state updates flush synchronously.
(globalThis as { IS_REACT_ACT_ENVIRONMENT?: boolean }).IS_REACT_ACT_ENVIRONMENT =
  true;

type Listener = (event: { matches: boolean }) => void;

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
  };
};

const isDark = () => document.documentElement.classList.contains('dark');

describe('ThemePreferenceControl', () => {
  let roots: Root[] = [];
  let containers: HTMLElement[] = [];

  const render = () => {
    const container = document.createElement('div');
    document.body.appendChild(container);
    const root = createRoot(container);
    act(() => root.render(<ThemePreferenceControl />));
    roots.push(root);
    containers.push(container);
    return container;
  };

  const option = (container: HTMLElement, label: string) =>
    container.querySelector<HTMLInputElement>(
      `input[type="radio"][value="${label}"]`
    )!;

  const choose = (container: HTMLElement, value: string) =>
    act(() => option(container, value).click());

  beforeEach(() => {
    localStorage.clear();
    document.documentElement.className = '';
  });

  afterEach(() => {
    roots.forEach((root) => act(() => root.unmount()));
    containers.forEach((container) => container.remove());
    roots = [];
    containers = [];
    vi.unstubAllGlobals();
  });

  it('offers light, dark and system as a labelled radio group', () => {
    stubSystemScheme(false);
    const container = render();
    expect(container.querySelector('fieldset legend')?.textContent).toBe(
      'Theme'
    );
    const radios = container.querySelectorAll('input[type="radio"]');
    expect(Array.from(radios).map((radio) => radio.getAttribute('value'))).toEqual(
      ['light', 'dark', 'system']
    );
    radios.forEach((radio) =>
      expect(radio.closest('label')?.textContent?.trim()).not.toBe('')
    );
  });

  it('defaults to system and follows the OS scheme', () => {
    const system = stubSystemScheme(true);
    const container = render();
    expect(option(container, 'system').checked).toBe(true);
    expect(isDark()).toBe(true);

    act(() => system.setDark(false));
    expect(isDark()).toBe(false);
  });

  it('lets an explicit choice override the OS and persists it', () => {
    const system = stubSystemScheme(true);
    const container = render();

    choose(container, 'light');
    expect(isDark()).toBe(false);
    expect(localStorage.getItem(STORAGE_KEY)).toBe('light');

    act(() => system.setDark(true));
    expect(isDark()).toBe(false);

    choose(container, 'dark');
    act(() => system.setDark(false));
    expect(isDark()).toBe(true);
  });

  it('returns to following the OS when system is chosen again', () => {
    const system = stubSystemScheme(false);
    const container = render();
    choose(container, 'dark');
    choose(container, 'system');
    expect(isDark()).toBe(false);
    act(() => system.setDark(true));
    expect(isDark()).toBe(true);
  });

  it('restores a stored preference on load', () => {
    stubSystemScheme(false);
    localStorage.setItem(STORAGE_KEY, 'dark');
    const container = render();
    expect(option(container, 'dark').checked).toBe(true);
    expect(isDark()).toBe(true);
  });

  it('keeps two controls on one page in agreement', () => {
    stubSystemScheme(false);
    const navbar = render();
    const accountPage = render();
    choose(accountPage, 'dark');
    expect(option(navbar, 'dark').checked).toBe(true);
  });
});
