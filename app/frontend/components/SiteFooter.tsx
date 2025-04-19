import React from "react";
import useLayoutNav from "@/hooks/useLayoutNav";

const SiteFooter = () => {
  const { siteLogo, footerCompanyLinks, footerResourceLinks } = useLayoutNav();
  const copyrightYear = new Date().getFullYear();

  console.debug({ footerResourceLinks });

  return (
    <footer className="bg-white sm:p-6 dark:bg-gray-800">
      <div className="w-full mx-auto max-w-screen-xl p-4 md:py-8">
        <div className="md:flex md:justify-between">
          <div className="mb-6 md:mb-0">
            {siteLogo && (
              <a
                href="https://madebylar.city/"
                className="flex items-center mb-4 sm:mb-0 space-x-3 rtl:space-x-reverse"
              >
                <img
                  src={siteLogo.url}
                  className="logo h-16"
                  alt={siteLogo?.aria_label}
                />
              </a>
            )}
          </div>
          <div className="grid grid-cols-2 gap-8 sm:gap-6 md:grid-cols-4">
            <div>
              <h2 className="mb-6 text-sm font-semibold text-gray-900 uppercase dark:text-white">
                Company
              </h2>
              <ul className="text-gray-600 dark:text-gray-400">
                {!!footerCompanyLinks &&
                  footerCompanyLinks.map(({ label, href }) => (
                    <li className="mb-4">
                      <a href={href} className="hover:underline me-4 md:me-6">
                        {label}
                      </a>
                    </li>
                  ))}
              </ul>
            </div>
            <div>
              <h2 className="mb-6 text-sm font-semibold text-gray-900 uppercase dark:text-white">
                Resources
              </h2>
              <ul className="text-gray-600 dark:text-gray-400">
                {!!footerResourceLinks &&
                  footerResourceLinks.length > 0 &&
                  footerResourceLinks.map(([label, href]) => (
                    <li className="mb-4">
                      <a
                        href={href}
                        className="hover:underline"
                        target="_blank"
                      >
                        {label}
                      </a>
                    </li>
                  ))}
              </ul>
            </div>
            <div>
              <h2 className="mb-6 text-sm font-semibold text-gray-900 uppercase dark:text-white">
                Follow us
              </h2>
              <ul className="text-gray-600 dark:text-gray-400">
                <li className="mb-4">
                  <a
                    href="https://github.com/larcitylab"
                    className="hover:underline "
                  >
                    Github
                  </a>
                </li>
                <li>
                  <a
                    href="https://discord.gg/4eeurUVvTy"
                    className="hover:underline"
                  >
                    Discord
                  </a>
                </li>
              </ul>
            </div>
            <div>
              <h2 className="mb-6 text-sm font-semibold text-gray-900 uppercase dark:text-white">
                Legal
              </h2>
              <ul className="text-gray-600 dark:text-gray-400">
                <li className="mb-4">
                  <a
                    href="/app/legal/privacy"
                    className="hover:underline me-4 md:me-6"
                  >
                    Privacy
                  </a>
                </li>
                <li className="mb-4">
                  <a
                    href="/app/legal/terms"
                    className="hover:underline me-4 md:me-6"
                  >
                    Legal Terms
                  </a>
                </li>
              </ul>
            </div>
          </div>
        </div>
        <hr className="my-6 border-gray-200 sm:mx-auto dark:border-gray-700 lg:my-8" />
        <div className="sm:flex sm:items-center sm:justify-between">
          {/* Copyright Notice */}
          <span className="block text-sm text-gray-500 sm:text-center dark:text-gray-400">
            © {copyrightYear}{" "}
            <a href="https://madebylar.city/" className="hover:underline">
              LarCity LLC
            </a>
            . All Rights Reserved.
          </span>
          <div className="flex mt-4 space-x-6 sm:justify-center sm:mt-0">
            <a
              href="#"
              className="text-gray-500 hover:text-gray-900 dark:hover:text-white"
            >
              <i className="fa-brands fa-facebook-messenger">
                <span className="sr-only">Facebook Messenger</span>
              </i>
            </a>
            <a
              href="#"
              className="text-gray-500 hover:text-gray-900 dark:hover:text-white"
            >
              <i className="fa-brands fa-medium">
                <span className="sr-only">Uche's Blog</span>
              </i>
            </a>
            <a
              href="https://github.com/larcitylab"
              className="text-gray-500 hover:text-gray-900 dark:hover:text-white"
            >
              <i className="fa-brands fa-github">
                <span className="sr-only">Github</span>
              </i>
            </a>
          </div>
        </div>
      </div>
    </footer>
  );
};

export default SiteFooter;
