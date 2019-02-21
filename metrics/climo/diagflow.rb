module EsmDiag
  class Diagflow_climo < Diagflow
    create_figure :precip
    create_figure :swcf
    create_figure :lwcf
    create_figure :zonal_mean
    create_figure :radiation_energy_budget
    create_figure :salinity
    create_figure :ice_area
    create_figure :energy_balance
  end
end
