module ScriniumEsmDiag
  class Diagflow_mjo < Diagflow
    create_figure :mean_state
    create_figure :variance_ratio
    create_figure :lag
    create_figure :wavenum_freq_spectra
    create_figure :combined_eof
  end
end
