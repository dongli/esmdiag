module EsmDiag
  class Actions
    def self.extract_accepted_options
      { :into_single_file => nil, :into_multiple_files => nil }
    end

    def self.extract comp, dataset, metric, tag, var, options
      output_file_name = ActionHelpers.create_file_name comp, var, tag
      return output_file_name if Cache.already_generated? output_file_name
      var_map = ConfigManager.model_info.send(comp).var_map
      if var_map.has_key? var.to_s
        old_name = var_map[var.to_s]["var_name"]
        if tag == :fixed
          cdo "select,name=#{old_name} #{dataset.data_list} #{output_file_name}"
        else
          cdo "select,name=#{old_name}," +
              "startdate=#{ConfigManager.date.start}," +
              "enddate=#{ConfigManager.date.end} " +
              "#{dataset.data_list} #{output_file_name}"
        end
        cdo "chname,#{old_name},#{var} #{output_file_name} #{output_file_name}.rename"
        EsmDiag.run "mv #{output_file_name}.rename #{output_file_name}"
      else
        if ConfigManager.model_info[comp][:invert_lat]
          if tag == :fixed
            cdo "invertlat -select,name=#{var} #{dataset.data_list} #{output_file_name}"
          else
            cdo "invertlat -select,name=#{var}," +
                "startdate=#{ConfigManager.date[:start]}," +
                "enddate=#{ConfigManager.date[:end]} " +
                "#{dataset.data_list} #{output_file_name}"
          end
        else
          if tag == :fixed
            cdo "select,name=#{var} #{dataset.data_list} #{output_file_name}"
          else
            cdo "select,name=#{var}," +
                "startdate=#{ConfigManager.date[:start]}," +
                "enddate=#{ConfigManager.date[:end]} " +
                "#{dataset.data_list} #{output_file_name}"
          end
        end
      end
      Cache.save_pipeline output_file_name
    end
  end
end
