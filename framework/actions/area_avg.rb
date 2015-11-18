module ScriniumEsmDiag
  class Actions
    def self.area_avg_accepted_options
      { :start_lon => Numeric, :end_lon => Numeric, :start_lat => Numeric, :end_lat => Numeric }
    end

    def self.area_avg dataset, metric, tag, var, options
      ActionHelpers.start(dataset.variables[var][:pipelines], options).each do |status_pipeline|
        pipeline = status_pipeline.last
        if status_pipeline.first == :active
          input_file_name = ActionHelpers.create_file_name var, tag, pipeline
          options[:regions].each do |area_tag, real_options|
            new_pipeline = "#{pipeline}.area_avg_#{area_tag}"
            output_file_name = ActionHelpers.create_file_name var, tag, new_pipeline
            if not Cache.already_generated? output_file_name
              real_options[:start_lon] ||= 0.0
              real_options[:end_lon] ||= 360.0
              real_options[:start_lat] ||= -90.0
              real_options[:end_lat] ||= 90.0
              ncl "#{ENV['SCRINIUM_ESM_DIAG_ROOT']}/ncl_scripts/area_avg.ncl " +
                "start_lon=#{real_options[:start_lon]} " +
                "end_lon=#{real_options[:end_lon]} " +
                "start_lat=#{real_options[:start_lat]} " +
                "end_lat=#{real_options[:end_lat]} " +
                "var_path=\\\"#{input_file_name}\\\" " +
                "var_name=\\\"#{var}\\\" " +
                "out_path=\\\"#{output_file_name}\\\""
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
