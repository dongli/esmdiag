load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ESMDIAG_ROOT/ncl_scripts/tools.ncl"

begin

  prefix = model_atm_id + "." + case_id
  suffix = start_date + ":" + end_date + ".nc"

  seasons = (/"ANN","JJA","DJF"/)
  num_season = dimsizes(seasons)

  f = addfile(prefix + ".pr.monthly." + suffix, "r")
  pr_mod   = f->pr
  lat_mod     = f->lat
  lon_mod     = f->lon
  num_lat_mod = dimsizes(lat_mod)
  num_lon_mod = dimsizes(lon_mod)

  ; 转换单位（TODO: 在其它地方做？）
  pr_mod = (/pr_mod*86400000/)
  pr_mod@units = "mm/day"

  tmp = clmMonTLL(pr_mod)
  pr_mod_climo = new((/num_season,num_lat_mod,num_lon_mod/), typeof(pr_mod))
  pr_mod_climo!1 = "lat"
  pr_mod_climo&lat = lat_mod
  pr_mod_climo!2 = "lon"
  pr_mod_climo&lon = lon_mod
  pr_mod_climo(0,:,:) = dim_avg_n_Wrap(tmp, 0)
  pr_mod_climo(1,:,:) = rm_single_dims(month_to_season(tmp, "JJA"))
  pr_mod_climo(2,:,:) = rm_single_dims(month_to_season(tmp, "DJF"))
  delete(tmp)

  f = addfile("$ESMDIAG_ROOT/obs/data/XIEARKIN_ANN_climo.nc", "r")
  pr_obs_ANN = rm_single_dims(f->PRECT)
  lat_obs = f->lat
  lon_obs = f->lon

  f = addfile("$ESMDIAG_ROOT/obs/data/XIEARKIN_JJA_climo.nc", "r")
  pr_obs_JJA = rm_single_dims(f->PRECT)

  f = addfile("$ESMDIAG_ROOT/obs/data/XIEARKIN_DJF_climo.nc", "r")
  pr_obs_DJF = rm_single_dims(f->PRECT)

  ; 选择将观测插值到模式格点？
  pr_obs_climo_i = new((/num_season,num_lat_mod,num_lon_mod/), typeof(pr_mod))
  copy_VarCoords(pr_mod_climo, pr_obs_climo_i)
  pr_obs_climo_i(0,:,:) = linint2(lon_obs, lat_obs, pr_obs_ANN, True, lon_mod, lat_mod, 0)
  pr_obs_climo_i(1,:,:) = linint2(lon_obs, lat_obs, pr_obs_JJA, True, lon_mod, lat_mod, 0)
  pr_obs_climo_i(2,:,:) = linint2(lon_obs, lat_obs, pr_obs_DJF, True, lon_mod, lat_mod, 0)

  wgt_lat = get_wgt_lat(model_atm_id, case_id, lat_mod)

  res_plot = common_plot_settings()
  res_plot@cnLinesOn = False
  res_plot@cnFillOn = True
  res_plot@mpLandFillColor = "white"
  res_plot@lbLabelStride = 2
  res_plot@tmLabelAutoStride = True
  res_plot@lbOrientation = "vertical"
  res_plot@mpCenterLonF = 180
  res_plot@cnLevelSelectionMode = "ExplicitLevels"

  res_panel = common_panel_settings()

  plot = new(3, graphic)

  do i = 0, num_season - 1
    diff = pr_mod_climo(i,:,:) - pr_obs_climo_i(i,:,:)
    diff!0 = "lat"
    diff&lat = lat_mod
    diff!1 = "lon"
    diff&lon = lon_mod

    wks = gsn_open_wks("pdf", prefix + ".climo.pr." + seasons(i))

    gsn_define_colormap(wks, "amwg")

    res_plot@gsnLeftString = model_atm_id + "@" + model_id
    res_plot@gsnRightString = "MEAN = " + sprintf("%4.2f", wgt_areaave(pr_mod_climo(i,:,:), wgt_lat, 1, 0))
    res_plot@cnLevels=(/0.2,0.5,1,2,3,4,5,6,7,8,9,10,12,14,17/)
    plot(0) = gsn_csm_contour_map_ce(wks, pr_mod_climo(i,:,:), res_plot)

    res_plot@gsnLeftString = "XIE-ARKIN"
    res_plot@gsnRightString = "MEAN = " + sprintf("%4.2f", wgt_areaave(pr_obs_climo_i(i,:,:), wgt_lat, 1, 0))
    plot(1) = gsn_csm_contour_map_ce(wks, pr_obs_climo_i(i,:,:), res_plot)

    res_plot@gsnLeftString = model_atm_id + "@" + model_id + " - XIE-ARKIN"
    res_plot@gsnRightString = "RMSE = "+sprintf("%4.2f", sqrt(wgt_areaave(diff^2, wgt_lat, 1, 0)))
    res_plot@cnLevels = (/-8,-6,-4,-3,-2,-1,-0.5,0,0.5,1,2,3,4,6,8/)
    plot(2) = gsn_csm_contour_map_ce(wks, diff, res_plot)

    res_panel@txString = case_id + ": " + seasons(i) + " " + start_date + " - " + end_date
    gsn_panel(wks, plot, (/3,1/), res_panel)
  end do

  ; 绘制对流性降水与格点尺度降水的比例。
  f = addfile(prefix + ".prc.monthly." + suffix, "r")
  prc_mod = f->prc

  ; 转换单位（TODO: 在其它地方做？）
  prc_mod = (/prc_mod*86400000/)
  prc_mod@units = "mm/day"

  prc_mod_climo = new((/num_season,num_lat_mod,num_lon_mod/), typeof(prc_mod))
  copy_VarCoords(pr_mod_climo, prc_mod_climo)
  tmp = clmMonTLL(prc_mod)
  prc_mod_climo(0,:,:) = dim_avg_n_Wrap(tmp, 0)
  prc_mod_climo(1,:,:) = rm_single_dims(month_to_season(tmp, "JJA"))
  prc_mod_climo(2,:,:) = rm_single_dims(month_to_season(tmp, "DJF"))

  f = addfile(prefix + ".prl.monthly." + suffix, "r")
  prl_mod = f->prl

  ; 转换单位（TODO: 在其它地方做？）
  prl_mod = (/prl_mod*86400000/)
  prl_mod@units = "mm/day"

  prl_mod_climo = new((/num_season,num_lat_mod,num_lon_mod/), typeof(prl_mod))
  copy_VarCoords(pr_mod_climo, prl_mod_climo)
  tmp = clmMonTLL(prl_mod)
  prl_mod_climo(0,:,:) = dim_avg_n_Wrap(tmp, 0)
  prl_mod_climo(1,:,:) = rm_single_dims(month_to_season(tmp, "JJA"))
  prl_mod_climo(2,:,:) = rm_single_dims(month_to_season(tmp, "DJF"))

  prc_mod_climo_ratio = prc_mod_climo/pr_mod_climo*100
  copy_VarCoords(prc_mod_climo, prc_mod_climo_ratio)
  prl_mod_climo_ratio = prl_mod_climo/pr_mod_climo*100
  copy_VarCoords(prl_mod_climo, prl_mod_climo_ratio)

  delete(res_plot)
  res_plot = common_plot_settings()
  res_plot@gsnStringFontHeightF = 0.02
  res_plot@lbLabelFontHeightF = 0.02
  res_plot@cnLinesOn = True
  res_plot@vpWidthF = 0.7
  res_plot@vpHeightF = 0.4
  res_plot@cnFillOn = True
  res_plot@lbOrientation = "vertical"
  res_plot@mpCenterLonF = 180
  res_plot@mpMinLonF = 100.
  res_plot@mpMaxLonF = 280.
  res_plot@mpMinLatF = -20.
  res_plot@mpMaxLatF = 20.
  res_plot@lbLabelAutoStride = True
  res_plot@cnLineLabelsOn = True
  res_plot@cnLineLabelFontThicknessF = 2
  res_plot@cnLevelSelectionMode = "ExplicitLevels"

  delete(plot)
  plot = new(2, graphic)

  do i = 0, num_season - 1
    wks = gsn_open_wks("pdf", prefix + ".climo.prc_vs_prl." + seasons(i))

    gsn_define_colormap(wks, "amwg")

    res_plot@gsnLeftString = model_atm_id + "@" + model_id
    res_plot@gsnRightString = "convective ratio"
    res_plot@cnLevels= fspan(60, 80, 11)
    plot(0) = gsn_csm_contour_map_ce(wks, prc_mod_climo_ratio(i,:,:), res_plot)

    res_plot@gsnLeftString = model_atm_id + "@" + model_id
    res_plot@gsnRightString = "stratiform ratio"
    res_plot@cnLevels= fspan(20, 40, 11)
    plot(1) = gsn_csm_contour_map_ce(wks, prl_mod_climo_ratio(i,:,:), res_plot)

    res_panel@txString = case_id + ": " + seasons(i) + " " + start_date + " - " + end_date
    gsn_panel(wks, plot, (/2,1/), res_panel)
  end do

end
