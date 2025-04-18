# frozen_string_literal: true

class DashboardController < ApplicationController
  include Demonstrable

  inertia_share navigation: demo_navigation_items

  layout 'inertiajs'

  def index
    render inertia: 'Dashboard', props: {
      name: 'Inertia Rails'
    }
  end
end
