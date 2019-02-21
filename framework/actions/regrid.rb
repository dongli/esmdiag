module EsmDiag
  class Actions
    def self.regrid_accepted_options
      { grid_file: nil, regrid_type: nil }
    end

    def self.regrid comp, dataset, metric, tag, var, options
      ActionHelpers.start(dataset.variables[var][:pipelines], options).each do |status_pipeline|
        pipeline = status_pipeline.last
        if status_pipeline.first == :active
          input_file_name = ActionHelpers.create_file_name comp, var, tag, pipeline
          pipeline << ".regrid_#{ConfigManager.regrid[comp][:to]}"
          output_file_name = ActionHelpers.create_file_name comp, var, tag, pipeline
          if not Cache.already_generated? output_file_name
            model_id = ConfigManager.model_info[comp][:id]
            src_grid_file = File.expand_path(options[:src_grid_file])
            CLI.report_error "Grid file #{options[:src_grid_file]} does not exist!" if not File.exist? src_grid_file
            dst_grid_file = "#{ENV['ESMDIAG_ROOT']}/grids/#{options[:dst_grid]}.nc"
            CLI.report_error "Grid file for #{options[:dst_grid]} does not exist!" if not File.exist? dst_grid_file
            regrid_type = options[:regrid_type] || 'bilinear'
            ncl_script = "#{ENV['ESMDIAG_ROOT']}/ncl_scripts/regrid.ncl"
            if File.exist? ncl_script
              ncl ncl_script, {
                model_id: model_id,
                dst_grid: options[:dst_grid],
                var_path: input_file_name,
                var_name: var,
                src_grid_file: src_grid_file,
                dst_grid_file: dst_grid_file,
                regrid_type: regrid_type,
                out_path: output_file_name
              }
            else
              CLI.under_construction!
            end
            Cache.save_pipeline output_file_name
          end
        end
        dataset.variables[var][:pipelines] << pipeline
      end
    end
  end
end
