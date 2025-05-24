import { useRef, useState, useCallback } from 'react';

const getCsrfTokenElement = () => {
  return document.querySelector<HTMLMetaElement>('meta[name="csrf-token"]');
};

export default function useCsrfToken() {
  const csrfTokenMetaTagRef = useRef<HTMLMetaElement | null>(
    getCsrfTokenElement()
  );
  const extractCsrfTokenFromMetaTag = useCallback(() => {
    return csrfTokenMetaTagRef.current?.getAttribute('content');
  }, []);
  const [csrfToken, setCsrfToken] = useState<string>(
    extractCsrfTokenFromMetaTag() ?? ''
  );

  return { csrfToken, setCsrfToken };
}
