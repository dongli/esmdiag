module ScriniumEsmDiag
  class Diagflow
    include DiagflowDSL

    attr_reader :figures

    def initialize
      metric = self.class.to_s.gsub(/ScriniumEsmDiag::Diagflow_/, '')
      eval "@figures = @@figures_#{metric}"
    end

    def run metric
      @figures.each do |tag, figure|
        # Using NCL to plot figure.
        ScriniumEsmDiag.run "ncl -Q #{ENV['SCRINIUM_ESM_DIAG_ROOT']}/metrics/#{metric}/plot_#{tag}.ncl " +
          "model_id=\\\"#{ConfigManager.model_id}\\\" " +
          "case_id=\\\"#{ConfigManager.case_id}\\\" " +
          "start_date=\\\"#{ConfigManager.date[:start]}\\\" " +
          "end_date=\\\"#{ConfigManager.date[:end]}\\\""
      end
    end
  end
end
