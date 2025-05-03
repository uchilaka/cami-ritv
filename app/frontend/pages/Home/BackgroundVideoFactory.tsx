import React, { useCallback, useEffect } from "react";

const BackgroundVideoFactory = () => {
  const appendVideo = useCallback(() => {
    const mainEl = document.querySelector("main");
    const videoEl = document.createElement("video");
    videoEl.id = "small-biz-b-roll";
    videoEl.autoplay = true;
    videoEl.loop = true;
    const sourceEl = document.createElement("source");
    sourceEl.type = "video/mp4";
    sourceEl.src =
      "//storage.googleapis.com/com-larcity-assets/videos/SmallBizBRoll/960x540.mp4";
    videoEl.appendChild(sourceEl);
    mainEl?.prepend(videoEl);
  }, []);

  const destroyVideo = useCallback(() => {
    const videoEl = document.getElementById(
      "small-biz-b-roll"
    ) as HTMLVideoElement;
    if (videoEl) {
      videoEl.pause();
      videoEl.remove();
    }
  }, []);

  useEffect(() => {
    void appendVideo();

    return () => destroyVideo();
  }, []);

  return <></>;
};

export default BackgroundVideoFactory;
