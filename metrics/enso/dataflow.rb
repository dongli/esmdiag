module EsmDiag
  class Dataflow_enso < Dataflow
    create_dataset :atm, :monthly do
      requires :FSNS, :FSNSC, :PRECT, :PRECC, :PRECL
      extract :all
      remove_annual_cycle :all
      anomaly :all
    end
    create_dataset :ocn, :monthly do
      requires :SST
      extract :all
      remove_annual_cycle :SST
      anomaly :SST
    end
  end
end
