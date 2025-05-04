# frozen_string_literal: true

class LobbyController < ApplicationController
  layout 'inertiajs'

  # TODO: This should render the marketing home page
  def index
    render inertia: 'Lobby', props: {
      name: 'Inertia Rails',
    }
  end

  def landing_page
    render inertia: 'Home/index', props: {
      title: 'Welcome to LarCity',
    }
  end

  def background_video
    render inertia: 'Home/BackgroundVideo', props: {
      title: 'Welcome to LarCity (Background Video)',
    }
  end

  def about_us
    render inertia: 'WhatWeDo', props: {
      title: 'What We Do',
    }
  end
end
