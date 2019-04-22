load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ESMDIAG_ROOT/ncl_scripts/tools.ncl"

begin

  prefix = model_id + "." + case_id
  suffix = start_date + ":" + end_date + ".nc"

  summer = (/4,5,6,7,8,9/)
  winter = (/10,11,0,1,2,3/)

  f = addfile(prefix + ".OLR.monthly." + suffix, "r")
  OLR_clm = clmMonTLL(f->OLR)
  OLR_clm_summer = dim_avg_n_Wrap(OLR_clm(summer,:,:), 0)
  OLR_clm_winter = dim_avg_n_Wrap(OLR_clm(winter,:,:), 0)

  f = addfile(prefix + ".U.monthly.vinterp850:200." + suffix, "r")
  U850_clm = clmMonTLL(f->U(:,{850},:,:))
  U850_clm_summer = dim_avg_n_Wrap(U850_clm(summer,:,:), 0)
  U850_clm_winter = dim_avg_n_Wrap(U850_clm(winter,:,:), 0)

  f = addfile(prefix + ".PRC.monthly." + suffix, "r")
  PRC = 86400*1000*f->PRC
  copy_VarCoords(f->PRC, PRC)
  PRC@units = "mm/day"
  PRC_clm = clmMonTLL(PRC)
  PRC_clm_summer = dim_avg_n_Wrap(PRC_clm(summer,:,:), 0)
  PRC_clm_winter = dim_avg_n_Wrap(PRC_clm(winter,:,:), 0)

  plots = new(3, graphic)

  res = common_plot_settings()
  res@gsnStringFontHeightF = 0.02
  res@lbLabelFontHeightF = 0.015
  res@gsnLeftString = model_id
  res@mpMinLonF = 30.0
  res@mpMaxLonF = 300.0
  res@mpMinLatF = -35.0
  res@mpMaxLatF = 35.0
  res@mpCenterLonF = 180.0
  res@mpLandFillColor = "background"
  res@cnLinesOn = False
  res@cnFillOn = True
  res@cnFillDrawOrder = "Predraw"
  res@lbOrientation = "Vertical"
  res@lbBoxMinorExtentF = 0.1
  res@pmLabelBarOrthogonalPosF = -0.05

  res_olr = res
  res_olr@cnLevelSelectionMode = "ManualLevels"
  res_olr@cnMinLevelValF = 180.0
  res_olr@cnLevelSpacingF = 10.0
  res_olr@cnMaxLevelValF = 300.0
  res_olr@gsnRightString = "OLR (" + OLR_clm@units + ")"

  res_u850 = res
  res_u850@cnLevelSelectionMode = "ManualLevels"
  res_u850@cnMinLevelValF = -8.0
  res_u850@cnLevelSpacingF = 2.0
  res_u850@cnMaxLevelValF = 16.0
  res_u850@gsnRightString = "U850 (" + U850_clm@units + ")"

  res_prc = res
  res_prc@gsnSpreadColorStart = 6
  res_prc@cnLevelSelectionMode = "ManualLevels"
  res_prc@cnMinLevelValF = 2.0
  res_prc@cnLevelSpacingF = 1.0
  res_prc@cnMaxLevelValF = 14.0
  res_prc@gsnRightString = "PRC (" + PRC_clm@units + ")"

  res_panel = common_panel_settings()

  wks = gsn_open_wks("pdf", prefix + "mjo.mean_state.summer")

  gsn_define_colormap(wks, "amwg")

  plots(0) = gsn_csm_contour_map(wks, OLR_clm_summer, res_olr)
  plots(1) = gsn_csm_contour_map(wks, U850_clm_summer, res_u850)
  plots(2) = gsn_csm_contour_map(wks, PRC_clm_summer, res_prc)

  res_panel@txString = case_id + ": summer " + start_date + " - " + end_date
  gsn_panel(wks, plots, (/dimsizes(plots),1/), res_panel)

  wks = gsn_open_wks("pdf", prefix + "mjo.mean_state.winter")

  gsn_define_colormap(wks, "amwg")

  plots(0) = gsn_csm_contour_map(wks, OLR_clm_winter, res_olr)
  plots(1) = gsn_csm_contour_map(wks, U850_clm_winter, res_u850)
  plots(2) = gsn_csm_contour_map(wks, PRC_clm_winter, res_prc)

  res_panel@txString = case_id + ": winter " + start_date + " - " + end_date
  gsn_panel(wks, plots, (/dimsizes(plots),1/), res_panel)

end
