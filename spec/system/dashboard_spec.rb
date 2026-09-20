# frozen_string_literal: true

require 'rails_helper'

# Proves the browser harness reaches through the whole frontend pipeline:
# Rails -> Inertia -> Vite bundle -> React render. `name` is passed as an Inertia prop by
# DashboardController#index and only ever appears in the DOM if React actually ran.
RSpec.describe 'Dashboard', browser: true do
  it 'renders the React page with its Inertia props', :js do
    visit '/demos/hello-inertia-rails'

    expect(page).to have_content('Hello Inertia Rails!')
  end

  it 'does not render React content without JavaScript' do
    # Guards the test above: without a browser, Inertia emits only the mount point, so a
    # passing :js example proves React ran rather than the server having rendered the text.
    visit '/demos/hello-inertia-rails'

    expect(page).to have_no_content('Hello Inertia Rails!')
  end
end
