module ErrorLens
  class ApplicationController < ActionController::Base
    layout "error_lens"

    protect_from_forgery with: :exception
  end
end
