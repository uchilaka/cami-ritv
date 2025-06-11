import { useAppStoreWithDevtools as useStore } from '@/utils/store'

export const useSelectedInvoices = () => {
  return useStore((state) => state.selectedInvoicesMap)
}

export default useSelectedInvoices
