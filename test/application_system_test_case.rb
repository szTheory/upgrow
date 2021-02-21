# frozen_string_literal: true

require 'rails_helper'
require 'webdrivers/chromedriver'
require 'action_dispatch/system_testing/server'

ActionDispatch::SystemTesting::Server.silence_puma = true

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome do |options|
    options.add_argument('--disable-dev-shm-usage')
  end
end
