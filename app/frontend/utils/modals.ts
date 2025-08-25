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
