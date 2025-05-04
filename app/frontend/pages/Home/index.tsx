import React, { useCallback, useEffect, useRef } from "react";
import Typed from "typed.js";
import DemoLayout from "@/components/DemoLayout";
// import clsx from "clsx";
import { FCWithLayout } from "@/@types";
// import styles from "./Home.module.css";
import BackgroundVideo from "./BackgroundVideo";
import useFeatureFlags from "@/hooks/useFeatureFlags";

const Home: FCWithLayout = () => {
  const { featureFlags, isEnabled } = useFeatureFlags();
  const autoCursorEl = useRef<HTMLHeadingElement>(null);
  const scrollBlurEl = useRef<HTMLDivElement>(null);
  const typed = useRef<Typed | null>(null);

  console.debug({ featureFlags });

  const onStringTyped = (arrayPos: number, typist: Typed) => {
    console.debug({ arrayPos });
    typist.stop();
    /**
     * TODO: Switch the details text to the corresponding content
     *   indexed by `arrayPos`
     */
    setTimeout(() => typist.start(), arrayPos == 2 ? 5000 : 2500);
  };

  const initTypedAnimation = useCallback(
    (target: HTMLHeadingElement): Typed => {
      return new Typed(target, {
        strings: [
          // Discover the tools that will help you work smarter, not harder
          "Tech",
          // Do more with the tools you already use
          "Productivity",
          // Build the future of your business
          "Operations",
        ],
        typeSpeed: 35,
        backSpeed: 50,
        loop: true,
        loopCount: 5,
        onStringTyped,
      });
    },
    []
  );

  // Initialize Typed.js animation
  useEffect(() => {
    if (autoCursorEl.current)
      typed.current = initTypedAnimation(autoCursorEl.current);

    return () => {
      typed.current?.destroy();
    };
  }, []);

  // Initialize blur on scroll effect
  useEffect(() => {
    const handleScroll = () => {
      const scrollY = window.scrollY;
      const blurValue = Math.min(scrollY / 100, 10); // Cap the blur at 10px
      if (scrollBlurEl.current) {
        scrollBlurEl.current.style.backdropFilter = `blur(${blurValue}px)`;
      }
    };

    window.addEventListener("scroll", handleScroll);

    return () => {
      window.removeEventListener("scroll", handleScroll);
    };
  }, []);

  return (
    <>
      <BackgroundVideo />
      <div className="relative isolate z-30 px-6 pt-[22rem] sm:pt-[36rem] lg:px-8 min-h-[var(--lc-min-hero-height)]">
        {/* Top Blur Shape */}
        <div
          ref={scrollBlurEl}
          aria-hidden="true"
          className="absolute inset-x-0 -top-40 -z-10 transform-gpu overflow-hidden blur-3xl sm:-top-80"
        >
          <div className="relative left-[calc(50%-11rem)] aspect-1155/678 w-[36.125rem] -translate-x-1/2 rotate-[30deg] bg-gradient-to-tr from-[#ff80b5] to-[#9089fc] opacity-30 sm:left-[calc(50%-30rem)] sm:w-[72.1875rem] blur-shape" />
        </div>

        {/* Content Section */}
        <div className="mx-auto max-w-2xl py-32 sm:py-48 lg:py-56">
          {isEnabled("feat__marketing_announcements") && (
            <div className="hidden sm:mb-8 sm:flex sm:justify-center">
              <div className="relative rounded-full px-3 py-1 text-sm/6 ring-1 ring-gray-900/10 hover:ring-gray-900/30">
                Announcing our next round of funding.{" "}
                <a href="#" className="font-semibold text-indigo-600">
                  <span aria-hidden="true" className="absolute inset-0" />
                  Read more <span aria-hidden="true">&rarr;</span>
                </a>
              </div>
            </div>
          )}
          <div className="text-center">
            {/* TODO: A/B test the title style */}
            <h1 className="text-5xl font-semibold tracking-tight text-balance sm:text-7xl">
              Level Up Your
              <br />
              <span ref={autoCursorEl} />
            </h1>
            <p className="mt-8 text-lg font-medium text-pretty text-gray-900 sm:text-xl/8">
              Need to scale up your online business, automate digital marketing,
              or fine-tune your internet-based workflows? Get expert advice on
              using internet technology to run your small business or startup
              smarter. Let's talk!
            </p>
            <div className="mt-10 flex items-center justify-center gap-x-6">
              <a
                href="#"
                className="rounded-md bg-indigo-600 px-3.5 py-2.5 text-lg font-semibold text-white shadow-xs hover:bg-indigo-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
              >
                Get started today
              </a>
              <a href="#" className="text-lg/6 font-semibold text-gray-600">
                Learn more <span aria-hidden="true">→</span>
              </a>
            </div>
          </div>
        </div>
        <div
          aria-hidden="true"
          className="absolute inset-x-0 top-[calc(100%-13rem)] -z-10 transform-gpu overflow-hidden blur-3xl sm:top-[calc(100%-30rem)]"
        >
          <div
            style={{
              clipPath:
                "polygon(74.1% 44.1%, 100% 61.6%, 97.5% 26.9%, 85.5% 0.1%, 80.7% 2%, 72.5% 32.5%, 60.2% 62.4%, 52.4% 68.1%, 47.5% 58.3%, 45.2% 34.5%, 27.5% 76.7%, 0.1% 64.9%, 17.9% 100%, 27.6% 76.8%, 76.1% 97.7%, 74.1% 44.1%)",
            }}
            className="relative left-[calc(50%+3rem)] aspect-1155/678 w-[36.125rem] -translate-x-1/2 bg-linear-to-tr from-[#ff80b5] to-[#9089fc] opacity-30 sm:left-[calc(50%+36rem)] sm:w-[72.1875rem]"
          />
        </div>
      </div>
    </>
  );
};

Home.layout = DemoLayout;

export default Home;
