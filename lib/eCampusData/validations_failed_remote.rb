module ECampusData
  class ECampusData::ValidationsFailedRemote < StandardError
    attr_reader :args 
    def initialize(args)
      @args=args
    end     
  end
end