import React from "react";

const Appointment = () => {
  return (
    <>
      <div className="py-10">
        <div className="flex min-h-[var(--lc-min-hero-height)] flex-col justify-center max-w-7xl mx-auto sm:px-6 py-12 lg:px-8">
          <div className="bg-white rounded-lg p-4 lg:p-12">
            <h1 className="mb-4 text-4xl font-extrabold leading-none tracking-tight text-gray-900 md:text-5xl lg:text-6xl">
              Unlock results with{" "}
              <mark className="px-2 text-white bg-blue-600 rounded-sm dark:bg-blue-500">
                proven
              </mark>{" "}
              solutions
            </h1>
            <p className="text-lg font-normal text-gray-600 lg:text-xl">
              Schedule a free consultation - first one's on us
            </p>

            {/* <!-- Google Calendar Appointment Scheduling begin --> */}
            <iframe
              src="https://calendar.google.com/calendar/appointments/schedules/AcZssZ1c7ehq78rkwXcN_FF-xyHQHVOZkjfmlBdimqZXGlfaNbGqCDJzy7j8-aMoHs3aEKmDYbPuIKLK?gv=true"
              width="100%"
              height="600"
              className="min-h-[720px] border-0"
            ></iframe>
            {/* <!-- end Google Calendar Appointment Scheduling --> */}
          </div>
        </div>
      </div>
    </>
  );
};

export default Appointment;
