module ScriniumEsmDiag
  class DiagflowManager
    def self.run
      ConfigManager.use_metrics.each do |metric, options|
        load "#{ENV['SCRINIUM_ESM_DIAG_ROOT']}/metrics/#{metric}/diagflow.rb"
        diagflow = eval "Diagflow_#{metric}.new"
        diagflow.run metric
      end
    end
  end
end
