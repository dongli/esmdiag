module ScriniumEsmDiag
  class Diagflow_mjo < Diagflow
    create_figure :mean_state
    create_figure :variance_ratio
    create_figure :lag_lon
    create_figure :lag_lat
  end
end
