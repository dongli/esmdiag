module EsmDiag
  def self.attached_variables
    return @@attached_variables if defined? @@attached_variables
    @@attached_variables = {}
    ConfigManager.model_info.each do |comp, config|
      @@attached_variables[comp] = []
      if ConfigManager.model_info.send(comp).respond_to? :fixed
        case ConfigManager.model_info[comp][:grid].to_sym
        when :lat_lon, :latlon
          if ConfigManager.model_info.send(comp).fixed.respond_to? :wgt_lon
            @@attached_variables[comp] << ConfigManager.model_info.send(comp).fixed.wgt_lon
          end
          if ConfigManager.model_info.send(comp).fixed.respond_to? :wgt_lat
            @@attached_variables[comp] << ConfigManager.model_info.send(comp).fixed.wgt_lat
          end
        end
      end
    end
    @@attached_variables.delete_if { |comp, vars| vars.empty? }
  end
end
