import { createElement } from "react";
import { createRoot } from "react-dom/client";
import { createInertiaApp } from "@inertiajs/react";
import { InertiaProgress } from "@inertiajs/progress";
import axios from "axios";
import "flowbite";

import Layout from "@/components/Layout";
import { ReactNodeWithOptionalLayout, ResolvedComponent } from "@/@types";

document.addEventListener("DOMContentLoaded", () => {
  const csrfToken = document.querySelector<HTMLMetaElement>(
    "meta[name=csrf-token]"
  )?.content;
  if (!csrfToken) {
    throw new Error("CSRF token not found");
  }
  axios.defaults.headers.common["X-CSRF-Token"] = csrfToken;

  InertiaProgress.init();

  const candidateTargetEl =
    document.querySelector<HTMLDivElement>("#inertia-js-app");
  console.debug({ candidateTargetEl });

  void createInertiaApp({
    resolve: async (name) => {
      // Pass { eager: true } as options for import.meta.glob to eagerly load all pages
      const pages = import.meta.glob<ResolvedComponent>("../pages/**/*.tsx");
      const page = await pages[`../pages/${name}.tsx`]();
      if (!page) {
        throw new Error(`Missing Inertia page component: '${name}.tsx'`);
      }

      if (page.default) {
        // To use a default layout, import the Layout component
        // and use the following line.
        // see https://inertia-rails.dev/guide/pages#default-layouts
        (page.default as ReactNodeWithOptionalLayout).layout ||= Layout;
      }

      return page;
    },
    setup({ el, App, props }) {
      if (el) {
        el.classList.add("min-h-full");
        // TODO: Support rendering into an element that's already in the DOM (i.e. #inertia-js-app)
        createRoot(el).render(createElement(App, props));
      } else {
        throw new Error(
          "Missing root element.\n\n" +
            "If you see this error, it probably means you load Inertia.js on non-Inertia pages.\n" +
            'Consider moving <%= vite_typescript_tag "inertia" %> to the Inertia-specific layout instead.'
        );
      }
    },
  });
});
