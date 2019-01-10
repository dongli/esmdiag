module EsmDiag
  class Diagflow_climo < Diagflow
    create_figure :precip
    create_figure :swcf
    create_figure :lwcf
    create_figure :zonal_mean
    create_figure :radiation_energy_budget
  end
end
