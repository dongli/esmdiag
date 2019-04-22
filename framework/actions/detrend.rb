module EsmDiag
  class Actions
    def self.detrend_accepted_options
      { :dim => Integer }
    end

    def self.detrend comp, dataset, metric, tag, var, options
      ActionHelpers.start(dataset.variables[var][:pipelines], options).each do |status_pipeline|
        pipeline = status_pipeline.last
        if status_pipeline.first == :active
          input_file_name = ActionHelpers.create_file_name comp, var, tag, pipeline
          pipeline << '.detrended'
          output_file_name = ActionHelpers.create_file_name comp, var, tag, pipeline
          if not Cache.already_generated? output_file_name
            options[:dim] ||= 0
            ncl "#{ENV['ESMDIAG_ROOT']}/ncl_scripts/detrend.ncl", {
              var_path: input_file_name,
              var_name: var,
              dim: options[:dim],
              out_path: output_file_name
            }
            Cache.save_pipeline output_file_name
          end
        end
        dataset.variables[var][:pipelines] << pipeline
      end
    end
  end
end
