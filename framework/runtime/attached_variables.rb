module ScriniumEsmDiag
  def self.attached_variables
    return @@attached_variables if defined? @@attached_variables
    @@attached_variables = {}
    # 网格权重
    ConfigManager.model_data.each do |comp, config|
      @@attached_variables[comp] = []
      if ConfigManager.model_data[comp].has_key? :fixed
        case ConfigManager.model_data[comp][:fixed][:mesh]
        when :lat_lon
          if ConfigManager.model_data[comp][:fixed].include? :weight
            tmp = ConfigManager.model_data[comp][:fixed][:weight][:lon]
            @@attached_variables[comp] << tmp if tmp
            tmp = ConfigManager.model_data[comp][:fixed][:weight][:lat]
            @@attached_variables[comp] << tmp if tmp
          end
        end
      end
    end
    @@attached_variables.delete_if { |comp, vars| vars.empty? }
  end
end
