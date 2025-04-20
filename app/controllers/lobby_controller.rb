# frozen_string_literal: true

class LobbyController < ApplicationController
  layout 'inertiajs'

  # TODO: This should render the marketing home page
  def index
    render inertia: 'Lobby', props: {
      name: 'Inertia Rails',
    }
  end

  def about_us
    render inertia: 'WhatWeDo', props: {
      title: 'What We Do',
    }
  end
end
