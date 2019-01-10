module EsmDiag
  class DataflowManager
    def self.run
      ConfigManager.use_metrics.each do |metric, options|
        load "#{ENV['ESMDIAG_ROOT']}/metrics/#{metric}/dataflow.rb"
        dataflow = eval "Dataflow_#{metric}.new"
        dataflow.run metric
      end
    end
  end
end
