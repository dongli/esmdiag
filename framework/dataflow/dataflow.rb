module ScriniumEsmDiag
  class Dataflow
    include DataflowDSL

    attr_reader :datasets

    def initialize
      metric = self.class.to_s.gsub(/ScriniumEsmDiag::Dataflow_/, '')
      eval "@datasets = @@datasets_#{metric}"
      @datasets.each do |tag, dataset|
        if not dataset.root
          if ConfigManager.model_data[tag].has_key? :root
            dataset.root = ConfigManager.model_data[tag][:root]
          else
            dataset.root = ConfigManager.model_data[:root]
          end
          dataset.pattern = ConfigManager.model_data[tag][:pattern]
        end
        dataset.data_list = "#{dataset.root}/#{dataset.pattern}"
        dataset.variables.each_key do |var|
          dataset.variables[var][:pipelines] = [ '' ]
        end
      end
    end

    def run metric
      @datasets.each do |tag, dataset|
        dataset.variables.each do |var, actions|
          actions.each do |action, options|
            next if not Actions.respond_to? action
            Actions.send(action, dataset, metric, tag, var, options)
          end
        end
      end
    end
  end
end
