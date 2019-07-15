module EsmDiag
  class Dataflow_climo < Dataflow
    create_dataset :atm, :monthly do
      requires :ps, :prc, :prl, :pr, :swcf, :lwcf, :ua, :va, :ta, :hus,
               :rlut, :rlutcs, :rlus, :rlds, :rldscs,
               :rsut, :rsutcs, :rsus, :rsuscs, :rsdt, :rsds, :rsdscs,
               :hfls, :hfss
      extract :all
      vinterp :ua, :va, {
        on: [ 1000, 925, 850, 775, 700, 600, 500, 400, 300, 250, 200, 150, 100, 70, 50, 30, 10],
        interp_type: :linear,
        extrap: false
      }
      vinterp :hus, {
        on: [ 1000, 925, 850, 775, 700, 600, 500, 400, 300 ],
        interp_type: :linear,
        extrap: false
      }
      vinterp :ta, {
        on: [ 1000, 925, 850, 775, 700, 600, 500, 400, 300, 250, 200, 150, 100, 70, 50, 30, 10],
        interp_type: :log,
        extrap: false
      }
    end
    create_dataset :ocn, :monthly do
      requires :tos, :sos
      extract :all
    end
    create_dataset :ice, :monthly do
      requires :siconc, :sifb
      extract :all
    end
  end
end
