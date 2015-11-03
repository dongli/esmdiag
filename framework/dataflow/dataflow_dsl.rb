module ScriniumEsmDiag
  module DataflowDSL
    def self.included base
      base.extend self
    end

    def model_data_root arg
      @@info ||= {}
      @@info[:model_data_root] = arg
    end

    def model_id arg
      @@info ||= {}
      @@info[:model_id] = arg
    end

    def case_id arg
      @@info ||= {}
      @@info[:case_id] = arg
    end

    def create_dataset tag, &block
      @@dataset_blocks ||= {}
      raise "Already set a dataset with tag #{tag}" if @@dataset_blocks.has_key? tag
      @@dataset_blocks[tag] = block
    end
  end
end
