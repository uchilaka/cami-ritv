import React, { useState, useRef, useEffect, useCallback } from "react";

const BackgroundVideo = () => {
  const [useScrollBackgroundOpacityEffect] = useState(false);
  const scrollBlurRef = useRef<HTMLDivElement>(null);
  const videoRef = useRef<HTMLVideoElement>(null);

  const videoEventsListener = useCallback((ev: Event) => {
    const video = ev.target as HTMLVideoElement;
    if (video) {
      const logPrefix = `Video #${video.id}`;
      console.debug(`${logPrefix} event`, ev.type);
      switch (ev.type) {
        case "loadstart":
          console.debug(`${logPrefix} loading started`);
          break;
        case "loadeddata":
          console.debug(`${logPrefix} first frame has finished loading`);
          break;
        case "waiting":
          console.debug(`${logPrefix} waiting`);
          break;
        case "ended":
          console.debug(`${logPrefix} ended`);
          break;
        case "error":
          console.error(`${logPrefix} error`);
          break;
        case "suspend":
          console.debug(`${logPrefix} suspended`);
          break;
      }
    }
  }, []);

  useEffect(() => {
    if (videoRef.current) {
      // Events ref: https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/video#events
      videoRef.current.addEventListener("loadstart", videoEventsListener);
      videoRef.current.addEventListener("loadeddata", videoEventsListener);
      videoRef.current.addEventListener("waiting", videoEventsListener);
      videoRef.current.addEventListener("ended", videoEventsListener);
      videoRef.current.addEventListener("error", videoEventsListener);
      videoRef.current.addEventListener("suspend", videoEventsListener);
    }
  }, [videoRef.current]);

  // Initialize blur on scroll effect
  useEffect(() => {
    const handleScroll = () => {
      const scrollY = window.scrollY;
      const newBlurValue = Math.min(scrollY / 100, 10); // Cap the blur at 10px
      const newBgOpacityValue =
        Math.round(Math.min((scrollY + 425) / window.outerHeight, 0.8) * 100) /
        100.0;
      console.debug({ newBlurValue, newBgOpacityValue });
      if (scrollBlurRef.current) {
        const el = scrollBlurRef.current;
        el.style.backdropFilter = `blur(${newBlurValue}px)`;
        // Use the inverse color relative the current theme
        if (useScrollBackgroundOpacityEffect)
          el.style.background = `rgba(255, 255, 255, ${newBgOpacityValue})`;
      }
    };

    window.addEventListener("scroll", handleScroll);

    return () => {
      window.removeEventListener("scroll", handleScroll);
    };
  }, [useScrollBackgroundOpacityEffect]);

  return (
    <>
      <video
        ref={videoRef}
        id="small-biz-b-roll"
        autoPlay
        loop
        muted
        preload="auto"
        className="fixed z-0 top-0 start-0 w-[100vw] h-[100vh]"
      >
        <source
          src="//storage.googleapis.com/com-larcity-assets/videos/SmallBizBRoll/960x540.mp4"
          type="video/mp4"
        />
      </video>

      {/* Blur Overlay */}
      <div
        id="overlay"
        ref={scrollBlurRef}
        className="bg-white/40 fixed z-10 top-0 start-0 w-[100vw] h-[100vh]"
      ></div>
    </>
  );
};

export default BackgroundVideo;
