class Ifirma
  class Response
    attr_reader :code, :info, :invoice_id, :full_number, :body, :response

    def initialize(response)
      @response = response

      if response.body.instance_of?(Hash) && response.body["response"] && response.body["response"].instance_of?(Hash)
        @code = response.body["response"]["Kod"]
        @info = response.body["response"]["Informacja"]
        @invoice_id = response.body["response"]["Identyfikator"]
        @full_number = response.body["response"]["PelnyNumer"]
      end
    end

    def success?
      @code == 0 || @code.nil?
    end

    def error?
      @code > 0
    end

    def body
      response.body
    end
  end
end
