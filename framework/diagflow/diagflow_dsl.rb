module EsmDiag
  module DiagflowDSL
    def self.included base
      base.extend self
    end

    def create_figure tag, &block
      metric = self.to_s.gsub(/EsmDiag::Diagflow_/, '')
      eval "@@figures_#{metric} ||= {}"
      raise "Already set a figure with tag #{tag}" if eval "@@figures_#{metric}.has_key? tag"
      figure = Figure.new
      figure.instance_eval &block if block_given?
      eval "@@figures_#{metric}[tag] = figure"
    end

    def has_atm?
      ConfigManager.model_info.atm != nil
    end

    def has_ocn?
      ConfigManager.model_info.ocn != nil
    end

    def has_sea_ice?
      ConfigManager.model_info.ice != nil
    end
  end
end
