module ScriniumEsmDiag
  class Dataflow_apv_blocking < Dataflow
    create_dataset :daily do
      root "#{ConfigManager.model_data_root}/daily"
      requires :U, :V, :T, :Z3
      extract :all, :into_single_file => true
      vinterp :U, :V, :T, :Z3, {
        :on => [ 500, 400, 300, 200, 150 ],
        :interp_type => :log,
        :extrap => false
      }
      # calulates :apv
    end
  end
end
