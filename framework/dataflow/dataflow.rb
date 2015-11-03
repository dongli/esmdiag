module ScriniumEsmDiag
  class Dataflow
    include DataflowDSL

    attr_reader :datasets

    def initialize
      @@info.each { |key, value| instance_eval "def #{key}; \"#{value}\"; end" }
      @datasets = {}
      @@dataset_blocks.each do |tag, block|
        dataset = Dataset.new
        @@info.each { |key, value| dataset.instance_eval "def #{key}; \"#{value}\"; end" }
        dataset.instance_eval &block
        @datasets[tag] = dataset
      end
    end

    def run

    end
  end
end
