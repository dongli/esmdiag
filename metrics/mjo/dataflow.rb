module ScriniumEsmDiag
  class Dataflow_mjo < Dataflow
    create_dataset :monthly do
      requires :PS, :OLR, :PRC, :U, :V
      extract :all, :into_multiple_files => true
      vinterp :U, :V, {
        :on => [ 850, 200 ],
        :interp_type => :linear,
        :extrap => true
      }
    end

    create_dataset :daily do
      requires :PS, :OLR, :PRC, :U, :V
      extract :all, :into_multiple_files => true
      anomaly :OLR, :U, :V
      vinterp :U, :V, {
        :on => [ 850, 200 ],
        :interp_type => :linear,
        :extrap => true
      }
      filter :OLR, :PRC, :U, :V, {
        :method => :lanczos, :low_pass => 1.0/100.0, :high_pass => 1.0/20.0
      }
    end
  end
end
