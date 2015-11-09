load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

  suffix = start_date + ":" + end_date + ".nc"

  may_oct = (/4,5,6,7,8,9/)
  nov_apr = (/10,11,0,1,2,3/)

  f = addfile(case_id + ".OLR.monthly." + suffix, "r")
  OLR_clm = clmMonTLL(f->OLR)
  OLR_clm_may_oct = dim_avg_n_Wrap(OLR_clm(may_oct,:,:), 0)
  OLR_clm_nov_apr = dim_avg_n_Wrap(OLR_clm(nov_apr,:,:), 0)

  f = addfile(case_id + ".U.monthly.vinterp850:200." + suffix, "r")
  U850_clm = clmMonTLL(f->U(:,{850},:,:))
  U850_clm_may_oct = dim_avg_n_Wrap(U850_clm(may_oct,:,:), 0)
  U850_clm_nov_apr = dim_avg_n_Wrap(U850_clm(nov_apr,:,:), 0)

  f = addfile(case_id + ".PRC.monthly." + suffix, "r")
  PRC = 86400*1000*f->PRC
  copy_VarCoords(f->PRC, PRC)
  PRC@units = "mm/day"
  PRC_clm = clmMonTLL(PRC)
  PRC_clm_may_oct = dim_avg_n_Wrap(PRC_clm(may_oct,:,:), 0)
  PRC_clm_nov_apr = dim_avg_n_Wrap(PRC_clm(nov_apr,:,:), 0)

  plots = new(3, graphic)

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
  res_olr@cnMinLevelValF = 180.0
  res_olr@cnLevelSpacingF = 10.0
  res_olr@cnMaxLevelValF = 300.0
  res_olr@gsnLeftString = "OLR (" + OLR_clm@units + ")"

  res_u850 = res
  res_u850@cnLevelSelectionMode = "ManualLevels"
  res_u850@cnMinLevelValF = -8.0
  res_u850@cnLevelSpacingF = 2.0
  res_u850@cnMaxLevelValF = 16.0
  res_u850@gsnLeftString = "U850 (" + U850_clm@units + ")"

  res_prc = res
  res_prc@gsnSpreadColorStart = 6
  res_prc@cnLevelSelectionMode = "ManualLevels"
  res_prc@cnMinLevelValF = 2.0
  res_prc@cnLevelSpacingF = 1.0
  res_prc@cnMaxLevelValF = 14.0
  res_prc@gsnLeftString = "PRC (" + PRC_clm@units + ")"

  res_panel = True
  res_panel@gsnPanelYWhiteSpacePercent = 5

  wks = gsn_open_wks("pdf", case_id + ".may-oct.mean_state")

  gsn_define_colormap(wks, "amwg")

  plots(0) = gsn_csm_contour_map(wks, OLR_clm_may_oct, res_olr)
  plots(1) = gsn_csm_contour_map(wks, U850_clm_may_oct, res_u850)
  plots(2) = gsn_csm_contour_map(wks, PRC_clm_may_oct, res_prc)

  res_panel@gsnPanelMainString = "Mean State (May-Oct)"
  gsn_panel(wks, plots, (/dimsizes(plots),1/), res_panel)

  wks = gsn_open_wks("pdf", case_id + ".nov-apr.mean_state")

  gsn_define_colormap(wks, "amwg")

  plots(0) = gsn_csm_contour_map(wks, OLR_clm_nov_apr, res_olr)
  plots(1) = gsn_csm_contour_map(wks, U850_clm_nov_apr, res_u850)
  plots(2) = gsn_csm_contour_map(wks, PRC_clm_nov_apr, res_prc)

  res_panel@gsnPanelMainString = "Mean State (Nov-Apr)"
  gsn_panel(wks, plots, (/dimsizes(plots),1/), res_panel)

end
