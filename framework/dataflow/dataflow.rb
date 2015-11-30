module ScriniumEsmDiag
  class Dataflow
    include DataflowDSL

    attr_reader :datasets

    def initialize
      metric = self.class.to_s.gsub(/ScriniumEsmDiag::Dataflow_/, '')
      eval "@datasets = @@datasets_#{metric}"
      # 提取一些额外固定变量。
      ScriniumEsmDiag.attached_variables.each do |comp, vars|
        dataset = Dataset.new
        dataset.extract *vars
        @datasets[comp][:fixed] = dataset
      end
      @datasets.each do |comp, tags|
        tags.each do |tag, dataset|
          if not dataset.root
            if ConfigManager.model_data[comp][tag].has_key? :root
              dataset.root = ConfigManager.model_data[comp][tag][:root]
            else
              dataset.root = ConfigManager.model_data[comp][:root]
            end
            dataset.pattern = ConfigManager.model_data[comp][tag][:pattern]
          end
          dataset.data_list = "#{dataset.root}/#{dataset.pattern}" if not dataset.data_list
          dataset.variables.each_key do |var|
            dataset.variables[var][:pipelines] = [ '' ]
          end
          if @datasets[comp].has_key? :fixed and tag != :fixed and not @datasets[comp][:fixed].data_list
            @datasets[comp][:fixed].data_list = Dir.glob(File.expand_path dataset.data_list).first
          end
        end
      end
    end

    def run metric
      @datasets.each do |comp, tags|
        tags.each do |tag, dataset|
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
end
