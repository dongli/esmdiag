module EsmDiag
  class Diagflow_climo < Diagflow
    if has_atm?
      create_figure :precip
      create_figure :swcf
      create_figure :lwcf
      create_figure :zonal_mean
      create_figure :radiation_energy_budget
    end
    if has_ocn?
      create_figure :salinity
    end
    if has_sea_ice?
      create_figure :ice_area
      create_figure :energy_balance
    end
  end
end
