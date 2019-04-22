module EsmDiag
  class Actions
    def self.lon_avg_accepted_options
      { :start_lon => Numeric, :end_lon => Numeric }
    end

    def self.lon_avg comp, dataset, metric, tag, var, options
      ActionHelpers.start(dataset.variables[var][:pipelines], options).each do |status_pipeline|
        pipeline = status_pipeline.last
        if status_pipeline.first == :active
          input_file_name = ActionHelpers.create_file_name comp, var, tag, pipeline
          options[:regions].each do |lon_tag, real_options|
            new_pipeline = "#{pipeline}.lon_avg_#{lon_tag}"
            output_file_name = ActionHelpers.create_file_name comp, var, tag, new_pipeline
            if not Cache.already_generated? output_file_name
              real_options[:start_lon] ||= 0.0
              real_options[:end_lon] ||= 360.0
              ncl "#{ENV['ESMDIAG_ROOT']}/ncl_scripts/lon_avg.ncl", {
                start_lon: real_options[:start_lon],
                end_lon: real_options[:end_lon],
                var_path: input_file_name,
                var_name: var,
                out_path: output_file_name
              }
              Cache.save_pipeline output_file_name
            end
            dataset.variables[var][:pipelines] << new_pipeline
          end
        else
          dataset.variables[var][:pipelines] << pipeline
        end
      end
    end
  end
end
