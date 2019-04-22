module EsmDiag
  class Dataflow
    include DataflowDSL

    attr_reader :datasets

    def initialize
      metric = self.class.to_s.gsub(/EsmDiag::Dataflow_/, '')
      eval "@datasets = @@datasets_#{metric}"
      @datasets.each do |comp, tag_dataset_pairs|
        tag_dataset_pairs.each do |tag, dataset|
          if not dataset.root
            CLI.report_error "No #{comp} in model_data_info!" if not ConfigManager.model_data_info.has_key? comp
            CLI.report_error "No #{tag} in model_data_info->#{comp}!" if not ConfigManager.model_data_info[comp].has_key? tag
            if ConfigManager.model_data_info[comp].has_key? tag and ConfigManager.model_data_info[comp][tag].has_key? :root
              dataset.root = File.expand_path ConfigManager.model_data_info[comp][tag][:root]
            elsif ConfigManager.model_data_info[comp].has_key? :root
              dataset.root = File.expand_path ConfigManager.model_data_info[comp][:root]
            elsif ConfigManager.model_data_info.has_key? :root
              dataset.root = File.expand_path ConfigManager.model_data_info.root
            end
            dataset.pattern = ConfigManager.model_data_info[comp][tag][:pattern]
          end
          dataset.data_list = "#{dataset.root}/#{dataset.pattern}" if not dataset.data_list
          dataset.variables.each_key do |var|
            dataset.variables[var][:pipelines] = [ '' ]
          end
        end
      end
      EsmDiag.attached_variables.each do |comp, vars|
        selected_data = Dir.glob(@datasets[comp].values.first.data_list).first
        dataset = Dataset.new
        dataset.data_list = selected_data
        dataset.extract *vars
        @datasets[comp][:fixed] = dataset
      end
    end

    def run metric
      @datasets.each do |comp, tag_dataset_pairs|
        tag_dataset_pairs.reverse_each.to_h.each do |tag, dataset|
          dataset.variables.each do |var, actions|
            actions.each do |action, options|
              next if not Actions.respond_to? action
              Actions.send(action, comp, dataset, metric, tag, var, options)
              if action == :extract and ConfigManager.regrid and ConfigManager.regrid[comp]
                if not ConfigManager.model_info[comp][:grid_file]
                  CLI.report_error "No grid_file for regridding #{ConfigManager.model_info[comp][:id]}!"
                end
                Actions.send(:regrid, comp, dataset, metric, tag, var, {
                  src_grid_file: ConfigManager.model_info[comp][:grid_file],
                  dst_grid: ConfigManager.regrid[comp][:to]
                })
              end
            end
          end
        end
      end
    end
  end
end
