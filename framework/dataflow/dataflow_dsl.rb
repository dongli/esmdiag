module ScriniumEsmDiag
  module DataflowDSL
    def self.included base
      base.extend self
    end

    def create_dataset tag, &block
      metric = self.to_s.gsub(/ScriniumEsmDiag::Dataflow_/, '')
      eval "@@datasets_#{metric} ||= {}"
      raise "Already set a dataset with tag #{tag}" if eval "@@datasets_#{metric}.has_key? tag"
      dataset = Dataset.new
      dataset.instance_eval &block
      eval "@@datasets_#{metric}[tag] = dataset"
    end
  end
end
