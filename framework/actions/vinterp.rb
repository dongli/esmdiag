module ScriniumEsmDiag
  class Actions
    def self.vinterp_accepted_options
      { :on => Array, :interp_type => Symbol, :extrap => [ TrueClass, FalseClass ], :delete_input => [ TrueClass, FalseClass ] }
    end

    def self.vinterp dataset, metric, data_root, tag, var, options
      pipeline = dataset.variables[var][:pipeline]
      ps_path = "#{ConfigManager.case_id}.PS.#{tag}.#{ConfigManager.date[:start]}:#{ConfigManager.date[:end]}.nc"
      var_path = "#{ConfigManager.case_id}.#{var}.#{tag}#{pipeline}.#{ConfigManager.date[:start]}:#{ConfigManager.date[:end]}.nc"
      pipeline << ".vinterp#{options[:on].join(':')}"
      dataset.variables[var][:pipeline] = pipeline
      output_file_name = "#{ConfigManager.case_id}.#{var}.#{tag}#{pipeline}.#{ConfigManager.date[:start]}:#{ConfigManager.date[:end]}.nc"
      interp_type = options[:interp_type] ? { :linear => 1, :log => 2, :loglog => 3 }[options[:interp_type]] : 1
      extrap = options[:extrap] ? 'True' : 'False'
      ncl_script = "#{ENV['SCRINIUM_ESM_DIAG_ROOT']}/ncl_scripts/models/#{ConfigManager.model_id.downcase}/vinterp.ncl"
      return output_file_name if Cache.already_generated? output_file_name
      if File.exist? ncl_script
        ScriniumEsmDiag.run "ncl -Q #{ncl_script} " +
          "ps_path=\\\"#{ps_path}\\\" " +
          "var_path=\\\"#{var_path}\\\" " +
          "var_name=\\\"#{var}\\\" " +
          "'plevs=(/#{options[:on].join(',')}/)' " +
          "interp_type=#{interp_type} " +
          "extrap=#{extrap} "+
          "out_path=\\\"#{output_file_name}\\\""
      end
      FileUtils.rm_f var_path if options[:delete_input]
      output_file_name
    end
  end
end
