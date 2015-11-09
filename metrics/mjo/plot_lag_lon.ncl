load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl" 

begin

  suffix = start_date + ":" + end_date + ".nc"

  f = addfile(case_id + ".PRC.daily." + suffix, "r")
  PRC = f->PRC(time|:,{lat|-30:30},lon|:)

  f = addfile(case_id + ".PRC.daily.filtered." + suffix, "r")
  PRC_filtered = f->PRC(time|:,{lat|-30:30},lon|:)

  f = addfile(case_id + ".U.daily.anomaly.vinterp850:200." + suffix, "r")
  U850 = f->U(time|:,{lev_p|850},{lat|-30:30},lon|:)

  f = addfile(case_id + ".U.daily.anomaly.vinterp850:200.filtered." + suffix, "r")
  U850_filtered = f->U(time|:,{lev_p|850},{lat|-30:30},lon|:)

  start_lat_IO = -10.0
  end_lat_IO   =   5.0
  start_lon_IO =  75.0
  end_lon_IO   = 100.0

  wgt_lat = cos(0.017459*f->lat({start_lat_IO:end_lat_IO}))

  ; 计算IO区域平均的降水。
  PRC_IO = wgt_areaave_Wrap(PRC(time|:,{lat|start_lat_IO:end_lat_IO},{lon|start_lon_IO:end_lon_IO}), wgt_lat, 1.0, 1)
  PRC_IO_filtered = wgt_areaave_Wrap(PRC_filtered(time|:,{lat|start_lat_IO:end_lat_IO},{lon|start_lon_IO:end_lon_IO}), wgt_lat, 1.0, 1)

  ; 计算-10S~10N间的经向平均。
  PRC_time_lon = dim_avg_n_Wrap(PRC(time|:,{lat|-10:10},lon|:), 1)
  PRC_time_lon_filtered = dim_avg_n_Wrap(PRC_filtered(time|:,{lat|-10:10},lon|:), 1)

  U850_time_lon = dim_avg_n_Wrap(U850(time|:,{lat|-10:10},lon|:), 1)
  U850_time_lon_filtered = dim_avg_n_Wrap(U850(time|:,{lat|-10:10},lon|:), 1)

  ; 计算交叉相关。
  opt   = False
  mxlag = 25

  ccr_PRC_lag_lon = mjo_xcor_lag_season(PRC_IO, PRC_time_lon, mxlag, opt)
  ccr_PRC_lag_lon_filtered = mjo_xcor_lag_season(PRC_IO_filtered, PRC_time_lon_filtered, mxlag, opt)

  ccr_U850_lag_lon = mjo_xcor_lag_season(PRC_IO, U850_time_lon, mxlag, opt)
  ccr_U850_lag_lon_filtered = mjo_xcor_lag_season(PRC_IO_filtered, U850_time_lon_filtered, mxlag, opt)

  ; 调用函数绘图。
  opt = True
  opt@gsnLeftString = "PRC (color)"
  opt@gsnRightString = "U850 (lines)"
  opt@smth9 = 0.25

  mjo_xcor_lag_plot_ovly(ccr_PRC_lag_lon, ccr_U850_lag_lon, "pdf", ".", case_id + ".lag_lon", opt)
  mjo_xcor_lag_plot_ovly(ccr_PRC_lag_lon_filtered, ccr_U850_lag_lon_filtered, "pdf", ".", case_id + ".lag_lon.filtered", opt)

end
