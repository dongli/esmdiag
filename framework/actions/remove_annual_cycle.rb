module EsmDiag
  class Actions
    def self.remove_annual_cycle_accepted_options
      { :delete_input => [ TrueClass, FalseClass ] }
    end

    def self.remove_annual_cycle dataset, metric, tag, var, options
      ActionHelpers.start(dataset.variables[var][:pipelines], options).each do |status_pipeline|
        pipeline = status_pipeline.last
        if status_pipeline.first == :active
          input_file_name = ActionHelpers.create_file_name var, tag, pipeline
          pipeline << '.remove_annual_cycle'
          output_file_name = ActionHelpers.create_file_name var, tag, pipeline
          if not Cache.already_generated? output_file_name
            case tag
            when :daily
              cdo "ydaysub #{input_file_name} -ydaymean #{input_file_name} #{output_file_name}"
            when :monthly
              cdo "ymonsub #{input_file_name} -ymonmean #{input_file_name} #{output_file_name}"
            end
            Cache.save_pipeline output_file_name
          end
        end
        dataset.variables[var][:pipelines] << pipeline
      end
    end
  end
end
