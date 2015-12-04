load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$SCRINIUM_ESM_DIAG_ROOT/ncl_scripts/tools.ncl"

begin

  prefix = model_id + "." + case_id
  suffix = start_date + ":" + end_date + ".nc"

  start_lat = -5
  end_lat = 5
  start_lon_nino4 = 160
  end_lon_nino4 = 210
  start_lon_nino3 = 210
  end_lon_nino3 = 270

  f = addfile(prefix + ".FSNS.monthly.remove_annual_cycle.anomaly." + suffix, "r")
  FSNS = f->FSNS

  f = addfile(prefix + ".FSNSC.monthly.remove_annual_cycle.anomaly." + suffix, "r")
  FSNSC = f->FSNSC

  SWCF = FSNS - FSNSC

  lat = f->lat
  lon = f->lon

  f = addfile(prefix + ".SST.monthly.remove_annual_cycle.anomaly." + suffix, "r")
  SST = f->SST

  SST_nino3 = dim_avg_n_Wrap(SST(time|:,{lat|start_lat:end_lat},{lon|start_lon_nino3:end_lon_nino3}), (/1,2/))

  feedback = regCoef_n(SST_nino3, SWCF, 0, 0)
  feedback!0 = "lat"
  feedback&lat = lat
  feedback!1 = "lon"
  feedback&lon = lon

  feedback_nino3 = avg(feedback({lat|start_lat:end_lat},{lon|start_lon_nino3:end_lon_nino3}))
  feedback_nino4 = avg(feedback({lat|start_lat:end_lat},{lon|start_lon_nino4:end_lon_nino4}))

  wks = gsn_open_wks("pdf", prefix + "enso.shortwave_feedback")

  gsn_define_colormap(wks,"ViBlGrWhYeOrRe")

  res_plot = common_plot_settings()
  res_plot@gsnStringFontHeightF = 0.015
  res_plot@tmXBLabelFontHeightF = 0.015
  res_plot@tmYLLabelFontHeightF = 0.015
  res_plot@lbLabelFontHeightF = 0.015
  res_plot@cnFillOn = True
  res_plot@cnLinesOn = False
  res_plot@cnLevelSelectionMode = "ExplicitLevels"
  res_plot@cnLevels = (/-18,-15,-12,-9,-6,-3,-2,-1,0,1,2,3,6,9,12,15,18/)
  res_plot@mpCenterLonF = 210
  res_plot@mpMinLonF = 120
  res_plot@mpMaxLonF = 290
  res_plot@mpMinLatF = -30
  res_plot@mpMaxLatF = 30
  res_plot@pmLabelBarOrthogonalPosF = 0.2
  res_plot@gsnRightString = "NINO4: " + sprintf("%5.1f", feedback_nino4) + " " + \
                            "NINO3: " + sprintf("%5.1f", feedback_nino3)

  plot = gsn_csm_contour_map(wks, feedback, res_plot)

  draw(plot)
  frame(wks)

end
