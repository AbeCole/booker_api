module Booker
  class Error < StandardError
    attr_accessor :error, :description, :url, :request, :response, :argument_errors

    def initialize(url: nil, request: nil, response: nil)
      if request.present?
        self.request = request
      end

      if response.present?
        self.response = response
        error = response
        error = response["Fault"]["Detail"]["InternalErrorFault"] if response["Fault"]
        self.error = error['error'] || error['ErrorMessage']
        self.description = error['error_description']
        self.argument_errors = error["ArgumentErrors"].map { |a| { :attr => a["ArgumentName"], :message => a["ErrorMessage"] } } unless error["ArgumentErrors"].nil?
      end

      self.url = url
    end
  end

  class InvalidApiCredentials < Error; end
end
