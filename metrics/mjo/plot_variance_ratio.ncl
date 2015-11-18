load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

  prefix = model_id + "." + case_id
  suffix = start_date + ":" + end_date + ".nc"

  f = addfile(prefix + ".OLR.daily.anomaly." + suffix, "r")
  OLR_anomaly = f->OLR
  f = addfile(prefix + ".OLR.daily.anomaly.filtered." + suffix, "r")
  OLR_anomaly_filtered = f->OLR

  ; 设置时间编号。
  date = cd_calendar(f->time, 0)
  month = floattoint(date(:,1))
  may_oct = ind(month .ge. 5 .and. month .le. 10)
  nov_apr = ind((month .ge. 1 .and. month .le. 4) .or. (month .ge. 11 .and. month .le. 12))

  OLR_anomaly_variance_may_oct = dim_variance_n_Wrap(OLR_anomaly(may_oct,:,:), 0)
  OLR_anomaly_variance_nov_apr = dim_variance_n_Wrap(OLR_anomaly(nov_apr,:,:), 0)
  OLR_anomaly_filtered_variance_may_oct = dim_variance_n_Wrap(OLR_anomaly_filtered(may_oct,:,:), 0)
  OLR_anomaly_filtered_variance_nov_apr = dim_variance_n_Wrap(OLR_anomaly_filtered(nov_apr,:,:), 0)
  OLR_variance_ratio_may_oct = OLR_anomaly_filtered_variance_may_oct/OLR_anomaly_variance_may_oct*100
  OLR_variance_ratio_nov_apr = OLR_anomaly_filtered_variance_nov_apr/OLR_anomaly_variance_nov_apr*100
  OLR_variance_ratio_may_oct!0 = "lat"
  OLR_variance_ratio_may_oct!1 = "lon"
  OLR_variance_ratio_may_oct&lat = f->lat
  OLR_variance_ratio_may_oct&lon = f->lon
  copy_VarCoords(OLR_variance_ratio_may_oct, OLR_variance_ratio_nov_apr)

  f = addfile(prefix + ".U.daily.anomaly.vinterp850:200." + suffix, "r")
  U850_anomaly = f->U(:,{850},:,:)
  f = addfile(prefix + ".U.daily.anomaly.vinterp850:200.filtered." + suffix, "r")
  U850_anomaly_filtered = f->U(:,{850},:,:)

  U850_anomaly_variance_may_oct = dim_variance_n_Wrap(U850_anomaly(may_oct,:,:), 0)
  U850_anomaly_variance_nov_apr = dim_variance_n_Wrap(U850_anomaly(nov_apr,:,:), 0)
  U850_anomaly_filtered_variance_may_oct = dim_variance_n_Wrap(U850_anomaly_filtered(may_oct,:,:), 0)
  U850_anomaly_filtered_variance_nov_apr = dim_variance_n_Wrap(U850_anomaly_filtered(nov_apr,:,:), 0)
  U850_variance_ratio_may_oct = U850_anomaly_filtered_variance_may_oct/where(U850_anomaly_variance_may_oct .ne. 0, U850_anomaly_variance_may_oct, U850_anomaly_variance_may_oct@_FillValue)*100
  printMinMax(U850_variance_ratio_may_oct, 0)
  U850_variance_ratio_nov_apr = U850_anomaly_filtered_variance_nov_apr/where(U850_anomaly_variance_nov_apr .ne. 0, U850_anomaly_variance_nov_apr, U850_anomaly_variance_nov_apr@_FillValue)*100
  printMinMax(U850_variance_ratio_nov_apr, 0)
  U850_variance_ratio_may_oct!0 = "lat"
  U850_variance_ratio_may_oct!1 = "lon"
  U850_variance_ratio_may_oct&lat = f->lat
  U850_variance_ratio_may_oct&lon = f->lon
  copy_VarCoords(U850_variance_ratio_may_oct, U850_variance_ratio_nov_apr)

  plots = new(2, graphic)

  res = True
  res@gsnFrame = False
  res@gsnDraw = False
  res@gsnStringFontHeightF = 0.0125
  res@gsnSpreadColors = True
  res@gsnRightString = model_id + " - " + case_id
  res@mpMinLonF = 30.0
  res@mpMaxLonF = 300.0
  res@mpMinLatF = -35.0
  res@mpMaxLatF = 35.0
  res@mpCenterLonF = 180.0
  res@mpLandFillColor = "background"
  res@pmTickMarkDisplayMode = "Always"
  res@cnLinesOn = False
  res@cnFillOn = True
  res@cnFillDrawOrder = "Predraw"
  res@lbOrientation = "Vertical"
  res@lbLabelFontHeightF = 0.0125
  res@lbBoxMinorExtentF = 0.1
  res@pmLabelBarOrthogonalPosF = -0.05

  res_olr = res
  res_olr@cnLevelSelectionMode = "ManualLevels"
  res_olr@cnMinLevelValF = 10.0
  res_olr@cnLevelSpacingF = 5.0
  res_olr@cnMaxLevelValF = 50.0
  res_olr@gsnLeftString = "Anomaly: OLR variance ratio (%)"

  res_u850 = res
  res_u850@cnLevelSelectionMode = "ManualLevels"
  res_u850@cnMinLevelValF = 10.0
  res_u850@cnLevelSpacingF = 5.0
  res_u850@cnMaxLevelValF = 50.0
  res_u850@gsnLeftString = "Anomaly: U850 variance ratio (%)"

  res_panel = True
  res_panel@gsnPanelYWhiteSpacePercent = 5

  wks = gsn_open_wks("pdf", prefix + ".may-oct.variance_ratio")

  gsn_define_colormap(wks, "amwg")

  plots(0) = gsn_csm_contour_map(wks, OLR_variance_ratio_may_oct, res_olr)
  plots(1) = gsn_csm_contour_map(wks, U850_variance_ratio_may_oct, res_u850)

  res_panel@gsnPanelMainString = "Variance Ratio (May-Oct)"
  gsn_panel(wks, plots, (/dimsizes(plots),1/), res_panel)

  wks = gsn_open_wks("pdf", prefix + ".nov-apr.variance_ratio")

  gsn_define_colormap(wks, "amwg")

  plots(0) = gsn_csm_contour_map(wks, OLR_variance_ratio_nov_apr, res_olr)
  plots(1) = gsn_csm_contour_map(wks, U850_variance_ratio_nov_apr, res_u850)

  res_panel@gsnPanelMainString = "Variance Ratio (Nov-Apr)"
  gsn_panel(wks, plots, (/dimsizes(plots),1/), res_panel)

end
