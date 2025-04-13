import React, { ComponentProps, FC, ReactNode, forwardRef } from "react";
import clsx from "clsx";

export interface NavItem {
  name: string;
  href: string;
  submenu?: NavItem[];
}

const NavItemWithSubmenu: FC<
  ComponentProps<"button"> & {
    children: ReactNode;
    items: Array<Omit<NavItem, "submenu">>;
  }
> = forwardRef(({ id, items, children, className }, ref) => {
  const targetMenuId = `${id}--submenu`;
  return (
    <>
      <button
        ref={ref}
        id={id}
        data-dropdown-toggle={targetMenuId}
        className={clsx(className, "flex items-center justify-between w-full")}
      >
        {children}
        <svg
          className="w-2.5 h-2.5 ms-2.5"
          aria-hidden="true"
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 10 6"
        >
          <path
            stroke="currentColor"
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="m1 1 4 4 4-4"
          />
        </svg>
      </button>

      <div
        id={targetMenuId}
        className="z-10 hidden font-normal bg-white divide-y divide-gray-100 rounded-lg shadow-sm w-44 dark:bg-gray-700 dark:divide-gray-600"
      >
        <ul
          className="py-2 text-sm text-gray-700 dark:text-gray-400"
          aria-labelledby={id}
        >
          {items.map(({ name, href }) => (
            <li>
              <a
                href={href}
                className="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white"
              >
                {name}
              </a>
            </li>
          ))}
        </ul>
      </div>
    </>
  );
});

export default NavItemWithSubmenu;
