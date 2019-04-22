load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl" 

load "$ESMDIAG_ROOT/ncl_scripts/tools.ncl"

begin

  prefix = model_id + "." + case_id
  suffix = start_date + ":" + end_date + ".nc"

  f = addfile(prefix + ".PRC.daily.anomaly.area_avg_IO.detrended." + suffix, "r")
  PRC_IO = f->PRC

  f = addfile(prefix + ".PRC.daily.anomaly.area_avg_IO.detrended.filtered." + suffix, "r")
  PRC_IO_filtered = f->PRC

  f = addfile(prefix + ".PRC.daily.anomaly.lat_avg_lon_band.detrended." + suffix, "r")
  PRC_time_lon = f->PRC

  f = addfile(prefix + ".PRC.daily.anomaly.lon_avg_lat_band.detrended." + suffix, "r")
  PRC_time_lat = f->PRC(time|:,{lat|-30:30})

  f = addfile(prefix + ".PRC.daily.anomaly.lat_avg_lon_band.detrended.filtered." + suffix, "r")
  PRC_time_lon_filtered = f->PRC

  f = addfile(prefix + ".PRC.daily.anomaly.lon_avg_lat_band.detrended.filtered." + suffix, "r")
  PRC_time_lat_filtered = f->PRC(time|:,{lat|-30:30})

  f = addfile(prefix + ".U.daily.anomaly.vinterp850:200.lat_avg_lon_band.detrended." + suffix, "r")
  U850_time_lon = f->U(time|:,{lev_p|850},lon|:)

  f = addfile(prefix + ".U.daily.anomaly.vinterp850:200.lon_avg_lat_band.detrended." + suffix, "r")
  U850_time_lat = f->U(time|:,{lev_p|850},{lat|-30:30})

  f = addfile(prefix + ".U.daily.anomaly.vinterp850:200.lat_avg_lon_band.detrended.filtered." + suffix, "r")
  U850_time_lon_filtered = f->U(time|:,{lev_p|850},lon|:)

  f = addfile(prefix + ".U.daily.anomaly.vinterp850:200.lon_avg_lat_band.detrended.filtered." + suffix, "r")
  U850_time_lat_filtered = f->U(time|:,{lev_p|850},{lat|-30:30})

  date = cd_calendar(f->time, -2)

  seasons = (/"winter","summer","annual"/)

  opt_xcor   = False
  mxlag = 25

  opt_plot = common_plot_settings()
  opt_plot@colorTable = "BlueYellowRed"
  opt_plot@gsnLeftString = "PRC (color)"
  opt_plot@gsnRightString = "U850 (lines)"
  opt_plot@smth9 = 0.25

  do i = 0, dimsizes(seasons)-1
    ; 计算交叉相关。
    ccr_PRC_lag_lon = mjo_xcor_lag(PRC_IO, PRC_time_lon, date, mxlag, seasons(i), opt_xcor)
    ccr_PRC_lag_lon_filtered = mjo_xcor_lag(PRC_IO_filtered, PRC_time_lon_filtered, date, mxlag, seasons(i), opt_xcor)

    ccr_U850_lag_lon = mjo_xcor_lag(PRC_IO, U850_time_lon, date, mxlag, seasons(i), opt_xcor)
    ccr_U850_lag_lon_filtered = mjo_xcor_lag(PRC_IO_filtered, U850_time_lon_filtered, date, mxlag, seasons(i), opt_xcor)

    ccr_PRC_lag_lat = mjo_xcor_lag(PRC_IO, PRC_time_lat, date, mxlag, seasons(i), opt_xcor)
    ccr_PRC_lag_lat_filtered = mjo_xcor_lag(PRC_IO_filtered, PRC_time_lat_filtered, date, mxlag, seasons(i), opt_xcor)

    ccr_U850_lag_lat = mjo_xcor_lag(PRC_IO, U850_time_lat, date, mxlag, seasons(i), opt_xcor)
    ccr_U850_lag_lat_filtered = mjo_xcor_lag(PRC_IO_filtered, U850_time_lat_filtered, date, mxlag, seasons(i), opt_xcor)

    ; 调用函数绘图。
    opt_plot@txString = case_id + ": " + seasons(i) + " " + start_date + " - " + end_date
    mjo_xcor_lag_ovly_panel(ccr_PRC_lag_lon, ccr_U850_lag_lon, \
                            ccr_PRC_lag_lat, ccr_U850_lag_lat, \
                            "pdf", ".", prefix + ".mjo.lag." + seasons(i), opt_plot)
    mjo_xcor_lag_ovly_panel(ccr_PRC_lag_lon_filtered, ccr_U850_lag_lon_filtered, \
                            ccr_PRC_lag_lat_filtered, ccr_U850_lag_lat_filtered, \
                            "pdf", ".", prefix + ".mjo.lag.filtered." + seasons(i), opt_plot)
  end do

end
