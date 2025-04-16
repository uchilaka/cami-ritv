class DashboardController < ApplicationController
  layout 'inertiajs'

  def index
    render inertia: 'Dashboard', props: {
      name: 'Inertia Rails'
    }
  end
end
