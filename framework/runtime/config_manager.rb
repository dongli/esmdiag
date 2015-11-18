module ScriniumEsmDiag
  class ConfigManager
    PermittedKeys = %W[
      model_id
      case_id
      model_data
      date
      use_metrics
    ].freeze

    def self.init
      PermittedKeys.each do |key|
        class_eval "@@#{key} = nil"
        class_eval "def self.#{key}=(value); @@#{key} = value; end"
        class_eval "def self.#{key}; @@#{key}; end"
      end
    end

    def self.parse config_path
      config = File.open(config_path).read
      PermittedKeys.each do |key|
        config.gsub!(/^ *#{key} *=/, "self.#{key}=")
      end
      begin
        class_eval config
      rescue SyntaxError => e
        CLI.report_error "Failed to parse #{CLI.red config_path}!\n#{e}"
      end
      # 为了方便比较时间，将日期字符串变为Date对象。
      date[:start] = Date.parse(date[:start]) if date.has_key? :start
      date[:end] = Date.parse(date[:end]) if date.has_key? :end
    end
  end
end
