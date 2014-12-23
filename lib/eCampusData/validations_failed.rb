module ECampusData
  class ECampusData::ValidationsFailed < StandardError
    attr_reader :args 
    def initialize(args)
      @args=args
    end     
  end
end