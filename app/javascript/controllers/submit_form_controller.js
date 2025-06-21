import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  submit() {
    console.debug('SubmitFormController#submit called');
    // eslint-disable-next-line @typescript-eslint/no-unsafe-call
    this.element.requestSubmit();
  }
}
