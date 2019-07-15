module EsmDiag
  class ConfigManager
    DatasetSpec = { root: nil, pattern: nil }.freeze

    PermittedKeys = {
      model_info: {
        id: nil,
        atm: { id: nil, grid: nil, grid_file: nil, invert_lat: nil, fixed: nil },
        lnd: { id: nil, grid: nil, grid_file: nil, invert_lat: nil, fixed: nil },
        ocn: { id: nil, grid: nil, grid_file: nil, invert_lat: nil, fixed: nil },
        ice: { id: nil, grid: nil, grid_file: nil, invert_lat: nil, fixed: nil }
      },
      case_info: { id: nil },
      model_data_info: {
        root: nil,
        atm: { root: nil, monthly: DatasetSpec, daily: DatasetSpec },
        lnd: { root: nil, monthly: DatasetSpec, daily: DatasetSpec },
        ocn: { root: nil, monthly: DatasetSpec, daily: DatasetSpec },
        ice: { root: nil, monthly: DatasetSpec, daily: DatasetSpec }
      },
      date: { start: nil, end: nil },
      regrid: {
        atm: { to: nil },
        lnd: { to: nil },
        ocn: { to: nil },
        ice: { to: nil }
      },
      metrics: {}
    }.freeze

    PermittedKeys.each_key do |key|
      self.class_eval "def self.#{key}; items.#{key}; end"
    end

    def self.parse config_path
      config = JSON.parse(File.open(config_path).read)
      @@items = ConfigItem.new PermittedKeys, config
      
      # Replace <case_info.id> by real case id if there is <case_info.id>.
      items.model_data_info.root.gsub! '<case_info.id>', items.case_info.id
      @@items.date.start = Date.parse(@@items.date.start)
      @@items.date.end = Date.parse(@@items.date.end)
    end

    def self.items
      @@items || {}
    end
  end
end
