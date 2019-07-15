module EsmDiag
  class Dataflow
    include DataflowDSL

    attr_reader :datasets

    def initialize
      metric = self.class.to_s.gsub(/EsmDiag::Dataflow_/, '').to_sym
      eval "@datasets = @@datasets_#{metric}"
      @datasets.each do |comp, tag_dataset_pairs|
        next if ConfigManager.metrics.send(metric).respond_to? :only and not ConfigManager.metrics.send(metric).only.include? comp.to_s
        tag_dataset_pairs.each do |tag, dataset|
          CLI.report_notice "Initialize component #{comp} for #{metric} metric."
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
        # Load model variable mapping JSON file.
        ConfigManager.model_info[comp][:var_map] = JSON.parse(File.open("#{ENV['ESMDIAG_ROOT']}/models/#{ConfigManager.model_info.send(comp).id.downcase}_vars.json").read)
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
        next if ConfigManager.metrics.send(metric).respond_to? :only and not ConfigManager.metrics.send(metric).only.include? comp.to_s
        CLI.report_notice "Run diagnostics of component #{comp} for #{metric} metric."
        tag_dataset_pairs.each do |tag, dataset|
          CLI.report_notice "Process #{tag} ..."
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
