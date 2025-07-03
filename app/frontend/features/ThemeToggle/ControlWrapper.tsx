import React, { FC } from 'react';

const ControlWrapper: FC<{ children: React.ReactNode }> = ({ children }) => {
  return (
    <div className="min-w-[200px] flex justify-between content-center text-sm px-4 py-3 dark:text-white">
      <label className="content-center">Theme</label>
      {children}
    </div>
  );
};

export default ControlWrapper;
