module ScriniumEsmDiag
  class Actions
    def self.extract_accepted_options
      { :into_single_file => nil, :into_multiple_files => nil }
    end

    def self.extract dataset, metric, data_root, tag, var, options
      output_file_name = "#{ConfigManager.case_id}.#{var}.#{tag}.#{ConfigManager.date[:start]}:#{ConfigManager.date[:end]}.nc"
      return output_file_name if Cache.already_generated? output_file_name
      if ConfigManager.use_metrics[metric].has_key? :rename and ConfigManager.use_metrics[metric][:rename].values.include? var
        old_name = ConfigManager.use_metrics[metric][:rename].key(var)
        ScriniumEsmDiag.run "ncrcat -O -h -v #{old_name} #{data_root}/*.nc #{output_file_name}"
        ScriniumEsmDiag.run "ncrename -O -h -v #{old_name},#{var} #{output_file_name}"
      else
        ScriniumEsmDiag.run "ncrcat -O -h -v #{var} #{data_root}/*.nc #{output_file_name}"
      end
      output_file_name
    end
  end
end
