import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { initializeModal } from '@/utils/modals';

// Mirrors the markup of app/views/accounts/modal/_show.html.erb: a hidden
// flowbite modal whose close button lives inside a .hide-modal-action form.
const renderModalMarkup = () => {
  document.body.innerHTML = `
    <div id="account-summary-modal" tabindex="-1" aria-hidden="true"
         class="flowbite-modal hidden" data-modal-placement="center-center">
      <form class="hide-modal-action" action="#">
        <button type="submit" data-testid="close-modal">Close modal</button>
      </form>
      <a href="#" data-testid="edit-account">Edit</a>
    </div>
  `;
  return document.getElementById('account-summary-modal') as HTMLDivElement;
};

describe('initializeModal', () => {
  let $modal: HTMLDivElement;

  beforeEach(() => {
    // initializeModal logs its options; keep the test output quiet
    vi.spyOn(console, 'debug').mockImplementation(() => {});
    $modal = renderModalMarkup();
  });

  afterEach(() => {
    vi.restoreAllMocks();
    document.body.innerHTML = '';
  });

  it('is not inert while shown', () => {
    $modal.setAttribute('inert', '');
    const modal = initializeModal($modal);

    modal.show();

    expect($modal.hasAttribute('inert')).toBe(false);
    expect($modal.hasAttribute('aria-hidden')).toBe(false);
  });

  it('marks the modal inert when hidden', () => {
    const modal = initializeModal($modal);
    modal.show();

    modal.hide();

    expect($modal.hasAttribute('inert')).toBe(true);
    expect($modal.getAttribute('aria-hidden')).toBe('true');
  });

  it('moves focus out of the modal before hiding it from assistive tech', () => {
    const modal = initializeModal($modal);
    modal.show();
    const $closeBtn = $modal.querySelector<HTMLButtonElement>(
      '[data-testid="close-modal"]'
    )!;
    $closeBtn.focus();
    expect(document.activeElement).toBe($closeBtn);

    // Record where focus is at the moment aria-hidden lands, which is when
    // Chrome raises "Blocked aria-hidden on an element because its
    // descendant retained focus". A spy rather than a MutationObserver,
    // because observer callbacks run after the fact.
    let focusedWhenAriaHidden: Element | null = null;
    const setAttribute = $modal.setAttribute.bind($modal);
    vi.spyOn($modal, 'setAttribute').mockImplementation((name, value) => {
      if (name === 'aria-hidden')
        focusedWhenAriaHidden = document.activeElement;
      setAttribute(name, value);
    });

    $closeBtn.click();

    expect($modal.getAttribute('aria-hidden')).toBe('true');
    expect($modal.contains(focusedWhenAriaHidden)).toBe(false);
    expect($modal.contains(document.activeElement)).toBe(false);
  });

  it('also releases focus when flowbite closes the modal on Escape', () => {
    const modal = initializeModal($modal);
    modal.show();
    const $editLink = $modal.querySelector<HTMLAnchorElement>(
      '[data-testid="edit-account"]'
    )!;
    $editLink.focus();

    document.body.dispatchEvent(
      new KeyboardEvent('keydown', { key: 'Escape', bubbles: true })
    );

    expect(modal.isHidden()).toBe(true);
    expect($modal.contains(document.activeElement)).toBe(false);
    expect($modal.hasAttribute('inert')).toBe(true);
  });
});
