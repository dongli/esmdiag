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
      use_metrics: []
    }.freeze

    PermittedKeys.each_key do |key|
      self.class.send(:define_method, key) do
        @@item.send key
      end
    end

    def self.parse config_path
      config = JSON.parse(File.open(config_path).read)
      @@item = ConfigItem.new PermittedKeys, config
      @@item.date.start = Date.parse(@@item.date.start)
      @@item.date.end = Date.parse(@@item.date.end)
    end
  end
end
