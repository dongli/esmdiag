module ScriniumEsmDiag
  class DataflowManager
    def self.run
      ConfigManager.use_metrics.each do |metric|
        load "#{ENV['SCRINIUM_ESM_DIAG_ROOT']}/metrics/#{metric}/dataflow.rb"
        dataflow = eval "Dataflow_#{metric}.new"
        dataflow.run
      end
    end
  end
end
