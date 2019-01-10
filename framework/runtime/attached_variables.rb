module EsmDiag
  def self.attached_variables
    return @@attached_variables if defined? @@attached_variables
    @@attached_variables = {}
    # 网格权重
    ConfigManager.model_data.each do |comp, config|
      @@attached_variables[comp] = []
      if ConfigManager.model_data[comp].has_key? :fixed
        case ConfigManager.model_data[comp][:mesh].to_sym
        when :lat_lon
          if ConfigManager.model_data[comp][:fixed].include? :wgt_lon
            @@attached_variables[comp] << ConfigManager.model_data[comp][:fixed][:wgt_lon]
          end
          if ConfigManager.model_data[comp][:fixed].include? :wgt_lat
            @@attached_variables[comp] << ConfigManager.model_data[comp][:fixed][:wgt_lat]
          end
        end
      end
    end
    @@attached_variables.delete_if { |comp, vars| vars.empty? }
  end
end
