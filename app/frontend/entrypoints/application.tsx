import "@hotwired/turbo-rails";
import "@/utils/tent";
import { createElement } from "react";
import { createRoot } from "react-dom/client";
import { createInertiaApp } from "@inertiajs/react";
import { InertiaProgress } from "@inertiajs/progress";
import { InstanceOptions, Modal, ModalOptions } from "flowbite";
import axios from "axios";

import "flowbite/dist/flowbite.turbo";
import "./main.scss";

import Layout from "@/components/BasicLayout";
import { ReactNodeWithOptionalLayout, ResolvedComponent } from "@/@types";

document.addEventListener("turbo:frame-render", ({ target }) => {
  console.warn("<<< turbo:frame-render >>>");
  console.debug({ target });
});

document.addEventListener("turbo:frame-load", ({ target }) => {
  console.warn("<<< turbo:frame-load >>>");
  console.debug({ target });
  const modals = (target as HTMLElement).querySelectorAll<HTMLDivElement>(
    ".flowbite-modal"
  );
  if (modals) {
    console.debug(`Found ${modals.length} modal(s)`);
    modals.forEach((modalElement) => {
      console.debug({ modalElement });
      const hideModalActionForm = modalElement.querySelector<HTMLFormElement>(
        "form.hide-modal-action"
      );
      const hideModalBtn = hideModalActionForm?.querySelector(
        "button[type=submit]"
      );
      const modalOptions: ModalOptions = { closable: true };
      if (!modalElement) throw new Error("Modal element not found");
      // Initialize modal
      console.debug(`Initializing modal ${modalElement.id}`, { hideModalBtn });
      const instanceOptions: InstanceOptions = {
        id: modalElement.id,
        override: true,
      };
      const modal = new Modal(modalElement, modalOptions, instanceOptions);
      // When the turbo frame action (button) is triggered, hide the modal
      hideModalBtn?.addEventListener("click", () => {
        modal.hide();
      });
      // Assumes every incoming modal (via turbo:frame-load) is one that should be shown
      modal.show();
    });
  }
});

document.addEventListener("DOMContentLoaded", () => {
  const csrfToken = document.querySelector<HTMLMetaElement>(
    "meta[name=csrf-token]"
  )?.content;
  if (!csrfToken) {
    throw new Error("CSRF token not found");
  }
  axios.defaults.headers.common["X-CSRF-Token"] = csrfToken;

  const LayoutMeta = document.querySelector<HTMLMetaElement>("[name=layout]");
  if (LayoutMeta?.content === "inertia.js") {
    console.debug("Initializing Inertia.js app");
    InertiaProgress.init();
    void createInertiaApp({
      resolve: async (name) => {
        console.debug({ name });
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
          // el.classList.add("min-h-[var(--lc-min-hero-height)]");
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
  }
});
