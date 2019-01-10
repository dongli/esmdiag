module EsmDiag
  class Actions
    def self.filter_accepted_options
      { :method => Symbol, :low_pass => Numeric, :high_pass => Numeric, :delete_input => [ TrueClass, FalseClass ] }
    end

    def self.filter dataset, metric, tag, var, options
      ActionHelpers.start(dataset.variables[var][:pipelines], options).each do |status_pipeline|
        pipeline = status_pipeline.last
        if status_pipeline.first == :active
          input_file_name = ActionHelpers.create_file_name var, tag, pipeline
          pipeline << '.filtered'
          output_file_name = ActionHelpers.create_file_name var, tag, pipeline
          if not Cache.already_generated? output_file_name
            ncl "#{ENV['SCRINIUM_ESM_DIAG_ROOT']}/ncl_scripts/filter_#{options[:method]}.ncl " +
             "var_path=\\\"#{input_file_name}\\\" " +
             "var_name=\\\"#{var}\\\" " +
             "fca=#{options[:low_pass]} " +
             "fcb=#{options[:high_pass]} " +
             "out_path=\\\"#{output_file_name}\\\""
            Cache.save_pipeline output_file_name
          end
        end
        dataset.variables[var][:pipelines] << pipeline
      end
    end
  end
end
