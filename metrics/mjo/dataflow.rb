module ScriniumEsmDiag
  class Dataflow_mjo < Dataflow
    create_dataset :atm, :monthly do
      requires :PS, :OLR, :PRC, :U, :V
      extract :all, :into_multiple_files => true
      vinterp :U, :V, {
        :on => [ 850, 200 ],
        :interp_type => :linear,
        :extrap => true
      }
    end

    create_dataset :atm, :daily do
      requires :PS, :PRC, :OLR, :U, :V
      extract :all, :into_multiple_files => true
      anomaly :PRC, :OLR, :U, :V
      vinterp :U, :V, {
        :on => [ 850, 200 ],
        :interp_type => :linear,
        :extrap => true
      }
      area_avg :PRC, {
        :follow => :anomaly,
        :detour => true,
        :regions => {
          :IO => {
            :start_lon => 75.0,
            :end_lon => 100.0,
            :start_lat => -10.0,
            :end_lat => 5.0
          }
        }
      }
      lat_avg :PRC, :U, {
        :follow => [ :anomaly, :vinterp ],
        :detour => true,
        :use_wgt_lat => false,
        :regions => {
          :lon_band => {
            :start_lat => -10.0,
            :end_lat => 10.0
          }
        }
      }
      lon_avg :PRC, :U, {
        :follow => [ :anomaly, :vinterp ],
        :detour => true,
        :regions => {
          :lat_band => {
            :start_lon => 80.0,
            :end_lon => 100.0
          }
        }
      }
      detrend :PRC, :U, {
        :follow => [ :area_avg, :lat_avg, :lon_avg ],
        :detour => true
      }
      filter :OLR, :PRC, :U, :V, {
        :method => :butterworth, :low_pass => 1.0/100.0, :high_pass => 1.0/20.0
      }
    end
  end
end
