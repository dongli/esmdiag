load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl" 

begin

  prefix = model_id + "." + case_id
  suffix = start_date + ":" + end_date + ".nc"

  f = addfile(prefix + ".OLR.daily.anomaly." + suffix, "r")
  OLR = f->OLR(time|:,{lat|-10:10},lon|:)
  OLR_time_lon = dim_avg_n_Wrap(OLR, 1)

  f = addfile(prefix + ".U.daily.anomaly.vinterp850:200." + suffix, "r")
  U850 = f->U(time|:,{lev_p|850},{lat|-10:10},lon|:)
  U850_time_lon = dim_avg_n_Wrap(U850, 1)

  date = cd_calendar(f->time, -2)

  seasons = (/"winter","summer"/)

  opt_wavfrq = False
  opt_plot = True
  opt_plot@cnLinesOn = False

  do i = 0, dimsizes(seasons)-1
    wfs = mjo_wavenum_freq_season(OLR_time_lon, date, seasons(i), opt_wavfrq)
    opt_plot@tiMainString = seasons(i) + ": " + start_date + " - " + end_date
    mjo_wavenum_freq_season_plot(wfs, seasons(i), ".", "pdf", prefix + ".OLR.wavenum_freq_spectrum", opt_plot)
  end do

  do i = 0, dimsizes(seasons)-1
    wfs = mjo_wavenum_freq_season(U850_time_lon, date, seasons(i), opt_wavfrq)
    opt_plot@tiMainString = seasons(i) + ": " + start_date + " - " + end_date
    mjo_wavenum_freq_season_plot(wfs, seasons(i), ".", "pdf", prefix + ".U850.wavenum_freq_spectrum", opt_plot)
  end do

end
