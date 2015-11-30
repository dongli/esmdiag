load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$SCRINIUM_ESM_DIAG_ROOT/ncl_scripts/tools.ncl"

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
  summer = ind(month .ge. 5 .and. month .le. 10)
  winter = ind((month .ge. 1 .and. month .le. 4) .or. (month .ge. 11 .and. month .le. 12))

  OLR_anomaly_variance_summer = dim_variance_n_Wrap(OLR_anomaly(summer,:,:), 0)
  OLR_anomaly_variance_winter = dim_variance_n_Wrap(OLR_anomaly(winter,:,:), 0)
  OLR_anomaly_filtered_variance_summer = dim_variance_n_Wrap(OLR_anomaly_filtered(summer,:,:), 0)
  OLR_anomaly_filtered_variance_winter = dim_variance_n_Wrap(OLR_anomaly_filtered(winter,:,:), 0)
  OLR_variance_ratio_summer = OLR_anomaly_filtered_variance_summer/OLR_anomaly_variance_summer*100
  OLR_variance_ratio_winter = OLR_anomaly_filtered_variance_winter/OLR_anomaly_variance_winter*100
  OLR_variance_ratio_summer!0 = "lat"
  OLR_variance_ratio_summer!1 = "lon"
  OLR_variance_ratio_summer&lat = f->lat
  OLR_variance_ratio_summer&lon = f->lon
  copy_VarCoords(OLR_variance_ratio_summer, OLR_variance_ratio_winter)

  f = addfile(prefix + ".U.daily.anomaly.vinterp850:200." + suffix, "r")
  U850_anomaly = f->U(:,{850},:,:)
  f = addfile(prefix + ".U.daily.anomaly.vinterp850:200.filtered." + suffix, "r")
  U850_anomaly_filtered = f->U(:,{850},:,:)

  U850_anomaly_variance_summer = dim_variance_n_Wrap(U850_anomaly(summer,:,:), 0)
  U850_anomaly_variance_winter = dim_variance_n_Wrap(U850_anomaly(winter,:,:), 0)
  U850_anomaly_filtered_variance_summer = dim_variance_n_Wrap(U850_anomaly_filtered(summer,:,:), 0)
  U850_anomaly_filtered_variance_winter = dim_variance_n_Wrap(U850_anomaly_filtered(winter,:,:), 0)
  U850_variance_ratio_summer = U850_anomaly_filtered_variance_summer/where(U850_anomaly_variance_summer .ne. 0, U850_anomaly_variance_summer, U850_anomaly_variance_summer@_FillValue)*100
  U850_variance_ratio_winter = U850_anomaly_filtered_variance_winter/where(U850_anomaly_variance_winter .ne. 0, U850_anomaly_variance_winter, U850_anomaly_variance_winter@_FillValue)*100
  U850_variance_ratio_summer!0 = "lat"
  U850_variance_ratio_summer!1 = "lon"
  U850_variance_ratio_summer&lat = f->lat
  U850_variance_ratio_summer&lon = f->lon
  copy_VarCoords(U850_variance_ratio_summer, U850_variance_ratio_winter)

  plots = new(2, graphic)

  res_plot = common_plot_settings()
  res_plot@gsnStringFontHeightF = 0.02
  res_plot@gsnLeftString = model_id
  res_plot@mpMinLonF = 30.0
  res_plot@mpMaxLonF = 300.0
  res_plot@mpMinLatF = -35.0
  res_plot@mpMaxLatF = 35.0
  res_plot@mpCenterLonF = 180.0
  res_plot@mpLandFillColor = "background"
  res_plot@cnLinesOn = False
  res_plot@cnLineLabelsOn = False
  res_plot@cnFillOn = True
  res_plot@cnFillDrawOrder = "Predraw"

  res_u850 = res_plot
  res_u850@cnLevelSelectionMode = "ManualLevels"
  res_u850@cnMinLevelValF = 10.0
  res_u850@cnLevelSpacingF = 5.0
  res_u850@cnMaxLevelValF = 50.0
  res_u850@gsnRightString = "Anomaly: U850 variance ratio (%)"
  res_u850@lbLabelBarOn = False

  res_olr = res_plot
  res_olr@cnLevelSelectionMode = "ManualLevels"
  res_olr@cnMinLevelValF = 10.0
  res_olr@cnLevelSpacingF = 5.0
  res_olr@cnMaxLevelValF = 50.0
  res_olr@gsnRightString = "Anomaly: OLR variance ratio (%)"
  res_olr@pmLabelBarOrthogonalPosF = 0.3

  res_panel = common_panel_settings()

  wks = gsn_open_wks("pdf", prefix + ".variance_ratio.summer")

  gsn_define_colormap(wks, "amwg")

  plots(0) = gsn_csm_contour_map(wks, U850_variance_ratio_summer, res_u850)
  plots(1) = gsn_csm_contour_map(wks, OLR_variance_ratio_summer, res_olr)

  res_panel@txString = case_id + ": summer " + start_date + " - " + end_date
  gsn_panel(wks, plots, (/dimsizes(plots),1/), res_panel)

  wks = gsn_open_wks("pdf", prefix + ".variance_ratio.winter")

  gsn_define_colormap(wks, "amwg")

  plots(0) = gsn_csm_contour_map(wks, U850_variance_ratio_winter, res_u850)
  plots(1) = gsn_csm_contour_map(wks, OLR_variance_ratio_winter, res_olr)

  res_panel@txString = case_id + ": winter " + start_date + " - " + end_date
  gsn_panel(wks, plots, (/dimsizes(plots),1/), res_panel)

end
