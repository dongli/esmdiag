module ScriniumEsmDiag
  class Actions
    def self.filter_accepted_options
      { :method => Symbol, :low_pass => Numeric, :high_pass => Numeric, :delete_input => [ TrueClass, FalseClass ] }
    end

    def self.filter dataset, metric, data_root, tag, var, options
      pipeline = dataset.variables[var][:pipeline]
      input_file_name = "#{ConfigManager.case_id}.#{var}.#{tag}#{pipeline}.#{ConfigManager.date[:start]}:#{ConfigManager.date[:end]}.nc"
      pipeline << '.filtered'
      dataset.variables[var][:pipeline] = pipeline
      output_file_name = "#{ConfigManager.case_id}.#{var}.#{tag}#{pipeline}.#{ConfigManager.date[:start]}:#{ConfigManager.date[:end]}.nc"
      ncl_script = "#{ENV['SCRINIUM_ESM_DIAG_ROOT']}/ncl_scripts/filter_#{options[:method]}.ncl"
      return output_file_name if Cache.already_generated? output_file_name
      ScriniumEsmDiag.run "ncl -Q #{ncl_script} " +
        "var_path=\\\"#{input_file_name}\\\" " +
        "var_name=\\\"#{var}\\\" " +
        "fca=#{options[:low_pass]} " +
        "fcb=#{options[:high_pass]} " +
        "out_path=\\\"#{output_file_name}\\\""
      FileUtils.rm_f input_file_name if options[:delete_input]
      output_file_name
    end
  end
end
