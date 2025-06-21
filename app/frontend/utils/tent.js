/* eslint-disable @typescript-eslint/no-unsafe-argument */
import '@hotwired/turbo-rails';
import '@rails/actiontext';
// import 'flowbite'
import 'trix';
import { Application } from '@hotwired/stimulus';
import { Turbo } from '@hotwired/turbo-rails';

// Stimulus controllers
import SubmitFormController from '../../javascript/controllers/submit_form_controller';

/**
 * We'll only enable Turbo drive features discretely, depending on the page.
 * https://github.com/hotwired/turbo-rails?tab=readme-ov-file#navigate-with-turbo-drive
 */
// eslint-disable-next-line @typescript-eslint/no-unsafe-member-access
Turbo.session.drive = false;

const stimulusApp = Application.start();
stimulusApp.debug = true;
window.Stimulus = stimulusApp;

// Register Stimulus controllers
stimulusApp.register('submit-form', SubmitFormController);

export { stimulusApp };
