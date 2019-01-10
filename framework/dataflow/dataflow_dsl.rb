module EsmDiag
  module DataflowDSL
    def self.included base
      base.extend self
    end

    def create_dataset comp, tag, &block
      metric = self.to_s.gsub(/EsmDiag::Dataflow_/, '')
      eval "@@datasets_#{metric} ||= {}"
      eval "@@datasets_#{metric}[comp] ||= {}"
      raise "Already set a dataset with tag #{tag}" if eval "@@datasets_#{metric}[comp].has_key? tag"
      dataset = Dataset.new
      dataset.instance_eval &block
      eval "@@datasets_#{metric}[comp][tag] = dataset"
    end
  end
end
