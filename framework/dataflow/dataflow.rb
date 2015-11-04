module ScriniumEsmDiag
  class Dataflow
    include DataflowDSL

    attr_reader :datasets

    def initialize
      @datasets = @@datasets
    end

    def run

    end
  end
end
