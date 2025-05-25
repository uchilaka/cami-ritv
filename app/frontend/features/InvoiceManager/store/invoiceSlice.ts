/* eslint-disable @typescript-eslint/no-unused-vars */
import { ChangeEvent } from 'react';
import { Invoice } from '@/features/InvoiceManager/types';
import { StateCreator } from 'zustand';
import { reduceInvoiceListToMap } from '../utils';
/**
 * See slice pattern: https://github.com/pmndrs/zustand/blob/main/docs/guides/slices-pattern.md
 */
export interface InvoiceSlice {
  invoicesMap: Record<string, Invoice>;
  selectedInvoicesMap: Record<string, boolean>;
  setInvoices: (invoices: Invoice[]) => void;
  // @deprecated Use setInvoices instead of setInvoicesMap
  setInvoicesMap: (invoiceMap: Record<string, Invoice>) => void;
  handleInvoiceSelectionChange: (ev: ChangeEvent<HTMLInputElement>) => void;
  // @deprecated Use handleInvoiceSelectionChange instead of setInvoiceSelectionInMap
  setInvoiceSelectionInMap: (invoiceId: string, checked: boolean) => void;
}

export const createInvoiceSlice: StateCreator<InvoiceSlice> = (set, _get) => ({
  invoicesMap: {},
  selectedInvoicesMap: {},
  setInvoices: (invoices: Invoice[]) =>
    set(
      slice => ({
        ...slice,
        invoicesMap: reduceInvoiceListToMap(invoices, slice.invoicesMap),
      }),
      true
    ),
  setInvoicesMap: (invoicesMap: Record<string, Invoice>) =>
    set(slice => {
      return {
        ...slice,
        invoicesMap,
      };
    }, true),
  setInvoiceSelectionInMap: (invoiceId: string, checked: boolean) =>
    set(slice => {
      return {
        ...slice,
        selectedInvoicesMap: {
          ...slice.selectedInvoicesMap,
          [invoiceId]: checked,
        },
      };
    }),
  handleInvoiceSelectionChange: (ev: ChangeEvent<HTMLInputElement>) =>
    set(slice => {
      console.warn('>> Invoice slice is about to be updated <<', { ...slice });
      const {
        invoicesMap,
        selectedInvoicesMap: currentMap,
        ...otherStuff
      } = slice;
      const { invoiceId } = ev.currentTarget.dataset;
      const { checked } = ev.currentTarget;
      // TODO: Support toggling all available invoices
      if (invoiceId) {
        switch (invoiceId) {
          case 'all':
            return {
              ...otherStuff,
              selectedInvoicesMap: {
                ...currentMap,
                ...Object.entries(invoicesMap).reduce(
                  (latestMap, [id, _invoice]) => ({
                    ...latestMap,
                    [id]: checked,
                  }),
                  {}
                ),
              },
            };

          default:
            return {
              ...otherStuff,
              selectedInvoicesMap: {
                ...currentMap,
                [invoiceId]: checked,
              },
            };
        }
      }
      return slice;
    }),
});
