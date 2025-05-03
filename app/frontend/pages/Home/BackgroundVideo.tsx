import React from "react";

const BackgroundVideoFactory = () => {
  return (
    <>
      <video
        autoPlay
        loop
        className="fixed z-0 top-0 start-0 w-[100vw] h-[100vh]"
      >
        <source
          src="//storage.googleapis.com/com-larcity-assets/videos/SmallBizBRoll/960x540.mp4"
          type="video/mp4"
        />
      </video>
      {/* <div
        id="overlay"
        className="fixed z-10 top-0 start-0 w-[100vw] h-[100vh]"
      ></div> */}
    </>
  );
};

export default BackgroundVideoFactory;
