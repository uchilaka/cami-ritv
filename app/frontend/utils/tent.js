import "@hotwired/turbo-rails";
import "@rails/actiontext";
// import 'flowbite'
import "trix";

import { Turbo } from "@hotwired/turbo-rails";

/**
 * We'll only enable Turbo drive features discretely, depending on the page.
 * https://github.com/hotwired/turbo-rails?tab=readme-ov-file#navigate-with-turbo-drive
 */
// eslint-disable-next-line @typescript-eslint/no-unsafe-member-access
Turbo.session.drive = false;
