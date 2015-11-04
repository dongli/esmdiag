module ScriniumEsmDiag
  class Dataflow_mjo < Dataflow
    create_dataset :monthly do
      requires :OLR, :PRC
      requires [ :U, :V ], :vinterp => {
        :on => [ 850, 200 ],
        :interp_type => :linear,
        :extrap => true
      }
    end

    create_dataset :daily do
      requires :OLR
      requires [ :U, :V ], :vinterp => {
        :on => [ 850, 200 ],
        :interp_type => :linear,
        :extrap => true
      }
      anomaly :all
      filter :all, {
        :method => :butterworth, :low_pass => 1.0/100.0, :high_pass => 1.0/20.0
      }
    end
  end
end
