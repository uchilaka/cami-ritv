import { createElement } from "react";
import { createRoot } from "react-dom/client";
import { createInertiaApp } from "@inertiajs/inertia-react";
import { InertiaProgress } from "@inertiajs/progress";
import axios from "axios";
import Layout from "@/components/Layout";
import { ModuleNamespace } from "vite/types/hot.js";

const pages = import.meta.glob("../pages/*.tsx");

document.addEventListener("DOMContentLoaded", () => {
  const csrfToken = document.querySelector<HTMLMetaElement>(
    "meta[name=csrf-token]"
  )?.content;
  if (!csrfToken) {
    throw new Error("CSRF token not found");
  }
  axios.defaults.headers.common["X-CSRF-Token"] = csrfToken;

  InertiaProgress.init();

  createInertiaApp({
    resolve: async (name) => {
      const PageNamespace = (await pages[
        `../pages/${name}.tsx`
      ]()) as ModuleNamespace;
      const page = PageNamespace.default;
      // const page = (await pages[`../pages/${name}.tsx`]()).default;
      page.layout = page.layout || Layout;

      return page;
    },
    setup({ el, App, props }) {
      const component = createRoot(el);
      component.render(createElement(App, props));
    },
  });
});
