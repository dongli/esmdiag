module ScriniumEsmDiag
  class Actions
    def self.anomaly_accepted_options
      { :delete_input => [ TrueClass, FalseClass ] }
    end

    def self.anomaly dataset, metric, data_root, tag, var, options
      pipeline = dataset.variables[var][:pipeline]
      input_file_name = "#{ConfigManager.case_id}.#{var}.#{tag}#{pipeline}.#{ConfigManager.date[:start]}:#{ConfigManager.date[:end]}.nc"
      pipeline << '.anomaly'
      dataset.variables[var][:pipeline] = pipeline
      output_file_name = "#{ConfigManager.case_id}.#{var}.#{tag}#{pipeline}.#{ConfigManager.date[:start]}:#{ConfigManager.date[:end]}.nc"
      return output_file_name if Cache.already_generated? output_file_name
      case tag
      when :daily
        ScriniumEsmDiag.run "cdo --history ydaysub #{input_file_name} -ydaymean #{input_file_name} #{output_file_name}"
      when :monthly
        ScriniumEsmDiag.run "cdo --history ymonsub #{input_file_name} -ymonmean #{input_file_name} #{output_file_name}"
      end
      FileUtils.rm_f input_file_name if options[:delete_input]
      output_file_name
    end
  end
end
