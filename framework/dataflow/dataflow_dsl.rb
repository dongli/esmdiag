module ScriniumEsmDiag
  module DataflowDSL
    def self.included base
      base.extend self
    end

    def create_dataset tag, &block
      @@datasets ||= {}
      raise "Already set a dataset with tag #{tag}" if @@datasets.has_key? tag
      dataset = Dataset.new
      dataset.instance_eval &block
      @@datasets[tag] = dataset
    end
  end
end
