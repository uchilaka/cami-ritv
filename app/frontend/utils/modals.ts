import { Modal, ModalOptions } from 'flowbite';
import capitalize from 'lodash.capitalize';

const SUPPORTED_MODAL_OPTIONS = ['backdrop', 'placement'] as const;

const parseModalOptionsFromDataset = (
  dataset: DOMStringMap
): Partial<ModalOptions> => {
  return SUPPORTED_MODAL_OPTIONS.reduce(
    (optionSet, optionKey) => ({
      ...optionSet,
      [optionKey]: dataset[`modal${capitalize(optionKey)}`],
    }),
    { closable: true }
  );
};

/**
 * flowbite's Modal.hide() sets aria-hidden="true" on the modal without moving
 * focus first, so dismissing it from a focused button inside leaves that
 * button focused under aria-hidden. Chrome then logs "Blocked aria-hidden on
 * an element because its descendant retained focus" (LAR-161).
 *
 * Wrapping the instance methods (rather than using the onHide/onShow
 * callbacks) matters twice over: onHide runs after aria-hidden is already
 * set, and an own-property `hide` shadows the prototype, so flowbite's own
 * Escape and backdrop-click handlers (which call this.hide()) go through it
 * too.
 *
 * `inert` is the attribute Chrome recommends in that warning: it hides the
 * subtree from assistive tech and also keeps focus out while it is hidden.
 */
const keepFocusOutOfHiddenModal = (modal: Modal, $targetEl: HTMLElement) => {
  const hide = modal.hide.bind(modal);
  const show = modal.show.bind(modal);

  modal.hide = () => {
    const $focused = document.activeElement;
    if ($focused instanceof HTMLElement && $targetEl.contains($focused)) {
      $focused.blur();
    }
    $targetEl.setAttribute('inert', '');
    hide();
  };

  modal.show = () => {
    $targetEl.removeAttribute('inert');
    show();
  };
};

export const initializeModal = ($targetEl: HTMLDivElement) => {
  if (!$targetEl) throw new Error('Modal element not found');
  const hideModalActionForm = $targetEl.querySelector<HTMLFormElement>(
    'form.hide-modal-action'
  );
  const hideModalBtn = hideModalActionForm?.querySelector(
    'button[type=submit]'
  );

  const modalOptions = parseModalOptionsFromDataset($targetEl.dataset);
  console.debug({ modalElement: $targetEl, modalOptions });

  // Initialize modal
  console.debug(`Initializing modal ${$targetEl.id}`, { hideModalBtn });
  const instanceOptions = {
    id: $targetEl.id,
    override: true,
  };
  const modal = new Modal($targetEl, modalOptions, instanceOptions);
  keepFocusOutOfHiddenModal(modal, $targetEl);
  // When the turbo frame action (button) is triggered, hide the modal
  hideModalBtn?.addEventListener('click', () => {
    modal.hide();
  });
  return modal;
};

export const initializeModalsOnFrameLoad = () => {
  document.addEventListener('turbo:frame-load', ({ target }) => {
    console.warn('<<< turbo:frame-load >>>');
    console.debug({ target });
    const modals = (target as HTMLElement).querySelectorAll<HTMLDivElement>(
      '.flowbite-modal'
    );
    if (modals) {
      console.debug(`Found ${modals.length} modal(s)`);
      modals.forEach(modalElement => {
        const modal = initializeModal(modalElement);
        // Assumes every incoming modal (via turbo:frame-load) is one that should be shown
        modal.show();
      });
    }
  });
};
