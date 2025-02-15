# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.

# --- Start of unicorn worker killer code ---

if ENV['RAILS_ENV'] == 'production'
  # Unicorn self-process killer
  require 'unicorn/worker_killer'

  # Max requests per worker
  use Unicorn::WorkerKiller::MaxRequests, 3072, 4096

  # Max memory size (RSS) per worker
  use Unicorn::WorkerKiller::Oom, (192 * (1024**2)), (256 * (1024**2))
end

# --- End of unicorn worker killer code ---

require File.expand_path('config/environment', __dir__)
run Icic::Application
