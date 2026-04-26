module ErrorLens
  class Configuration
    attr_accessor :ignored_exceptions, :filter_parameters

    def initialize
      @ignored_exceptions  = %w[ActionController::RoutingError]
      @filter_parameters   = %w[password password_confirmation token secret key credit_card cvv]
    end
  end
end
