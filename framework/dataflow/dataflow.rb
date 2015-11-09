module ScriniumEsmDiag
  class Dataflow
    include DataflowDSL

    attr_reader :datasets

    def initialize
      metric = self.class.to_s.gsub(/ScriniumEsmDiag::Dataflow_/, '')
      eval "@datasets = @@datasets_#{metric}"
      @datasets.each_value do |dataset|
        dataset.variables.each_key do |var|
          dataset.variables[var][:pipeline] = ''
        end
      end
    end

    def run metric
      @datasets.each do |tag, dataset|
        if not dataset.root
          dataset.root "#{ConfigManager.model_data_root}/#{tag}"
        end
        dataset.variables.each do |var, actions|
          actions.each do |action, options|
            next if not Actions.respond_to? action
            Cache.save_pipeline -> {
              if options
                Actions.send(action, dataset, metric, dataset.root, tag, var, options)
              else
                Actions.send(action, dataset, metric, dataset.root, tag, var)
              end
            }.call
          end
        end
      end
    end
  end
end
