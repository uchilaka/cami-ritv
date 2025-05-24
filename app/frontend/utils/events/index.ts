import { nsEventName } from '..';
import { BusinessAccount, IndividualAccount } from '../api/types';
import { LoadAccountEventDetail, LoadedAccountEventDetail } from '../types';

/**
 * TODO: Its seems I'm re-inventing the state management wheel here -
 *   perhaps I should look into using a state management library like Redux
 *   (be sure to take a look at redux toolkit), Zustand or Recoil to manage
 *   this state.
 */
export function emitLoadAccountEvent(accountId: string, source?: Element) {
  console.debug(`Will fire load event for account: ${accountId}`, { source });
  const event = new CustomEvent<LoadAccountEventDetail>(
    nsEventName('account:load'),
    {
      detail: {
        accountId,
      },
    }
  );
  (source ?? document).dispatchEvent(event);
}

export function emitAccountLoadedEvent(
  account: BusinessAccount | IndividualAccount,
  source?: Element
) {
  console.debug(`Will fire loaded event for account: ${account.id}`, {
    source,
  });
  const event = new CustomEvent<LoadedAccountEventDetail>(
    nsEventName('account:loaded'),
    {
      detail: { account },
    }
  );
  (source ?? document).dispatchEvent(event);
}

export function emitInvoiceSelectedEvent(
  selectionMap: Record<string, boolean>,
  source?: Element
) {
  console.debug(`Will fire selected event for invoice (sends selection map)`, {
    source,
    selectionMap,
  });
  const event = new CustomEvent(nsEventName('invoice:selected'), {
    detail: { selectionMap },
  });
  (source ?? document).dispatchEvent(event);
}
