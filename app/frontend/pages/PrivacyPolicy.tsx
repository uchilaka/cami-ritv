import React, { JSX } from 'react';
import BasicLayout from '@/components/BasicLayout';

function PrivacyPolicy(): JSX.Element {
  return (
    <div className="py-10">
      <div className="flex min-h-[var(--lc-min-hero-height)] leading-loose flex-col justify-center max-w-7xl mx-auto sm:px-6 py-12 lg:px-8">
        <h1 className="text-3xl font-bold leading-tight text-gray-900 mb-4">
          Privacy Notice
        </h1>
        <p>
          This privacy notice discloses the privacy practices for larcity.com.
          This privacy notice applies solely to information collected by this
          website. It will notify you of the following:
        </p>
        <p>
          What personally identifiable information is collected from you through
          the website, how it is used and with whom it may be shared. What
          choices are available to you regarding the use of your data. The
          security procedures in place to protect the misuse of your
          information. How you can correct any inaccuracies in the information.
          Information Collection, Use, and Sharing We are the sole owners of the
          information collected on this site. We only have access to/collect
          information that you voluntarily give us via email or other direct
          contact from you. We will not sell or rent this information to anyone.
        </p>
        <p>
          We will use your information to respond to you, regarding the reason
          you contacted us. We will not share your information with any third
          party outside of our organization, other than as necessary to fulfill
          your request, e.g. to ship an order.
        </p>
        <p>
          Unless you ask us not to, we may contact you via email in the future
          to tell you about specials, new products or services, or changes to
          this privacy policy.
        </p>
        <p>
          Your Access to and Control Over Information You may opt out of any
          future contacts from us at any time. You can do the following at any
          time by contacting us via the email address or phone number given on
          our website:
        </p>
        <p>
          See what data we have about you, if any. Change/correct any data we
          have about you. Have us delete any data we have about you. Express any
          concern you have about our use of your data. Security We take
          precautions to protect your information. When you submit sensitive
          information via the website, your information is protected both online
          and offline.
        </p>
        <p>
          Wherever we collect sensitive information (such as credit card data),
          that information is encrypted and transmitted to us in a secure way.
          You can verify this by looking for a lock icon in the address bar and
          looking for &ldquo;https&rdquo; at the beginning of the address of the
          Web page.
        </p>
        <p>
          While we use encryption to protect sensitive information transmitted
          online, we also protect your information offline. Only employees who
          need the information to perform a specific job (for example, billing
          or customer service) are granted access to personally identifiable
          information. The computers/servers in which we store personally
          identifiable information are kept in a secure environment.
        </p>
        <p>
          If you feel that we are not abiding by this privacy policy, you
          should contact us immediately via our website or via email @
          <a
            href="mailto:support@larcity.com"
            rel="noopener noreferrer"
            target="_blank"
          >
            support@larcity.com
          </a>
          .
        </p>
      </div>
    </div>
  );
}

PrivacyPolicy.layout = BasicLayout;

export default PrivacyPolicy;
