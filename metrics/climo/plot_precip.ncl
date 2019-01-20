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

  f = addfile(prefix + ".PRECT.monthly." + suffix, "r")
  PRECT_mod   = f->PRECT
  lat_mod     = f->lat
  lon_mod     = f->lon
  num_lat_mod = dimsizes(lat_mod)
  num_lon_mod = dimsizes(lon_mod)

  ; 转换单位（TODO: 在其它地方做？）
  PRECT_mod = (/PRECT_mod*86400000/)
  PRECT_mod@units = "mm/day"

  tmp = clmMonTLL(PRECT_mod)
  PRECT_mod_climo = new((/num_season,num_lat_mod,num_lon_mod/), typeof(PRECT_mod))
  PRECT_mod_climo!1 = "lat"
  PRECT_mod_climo&lat = lat_mod
  PRECT_mod_climo!2 = "lon"
  PRECT_mod_climo&lon = lon_mod
  PRECT_mod_climo(0,:,:) = dim_avg_n_Wrap(tmp, 0)
  PRECT_mod_climo(1,:,:) = rm_single_dims(month_to_season(tmp, "JJA"))
  PRECT_mod_climo(2,:,:) = rm_single_dims(month_to_season(tmp, "DJF"))
  delete(tmp)

  f = addfile("$ESMDIAG_ROOT/obs/data/XIEARKIN_ANN_climo.nc", "r")
  PRECT_obs_ANN = rm_single_dims(f->PRECT)
  lat_obs = f->lat
  lon_obs = f->lon

  f = addfile("$ESMDIAG_ROOT/obs/data/XIEARKIN_JJA_climo.nc", "r")
  PRECT_obs_JJA = rm_single_dims(f->PRECT)

  f = addfile("$ESMDIAG_ROOT/obs/data/XIEARKIN_DJF_climo.nc", "r")
  PRECT_obs_DJF = rm_single_dims(f->PRECT)

  ; 选择将观测插值到模式格点？
  PRECT_obs_climo_i = new((/num_season,num_lat_mod,num_lon_mod/), typeof(PRECT_mod))
  copy_VarCoords(PRECT_mod_climo, PRECT_obs_climo_i)
  PRECT_obs_climo_i(0,:,:) = linint2(lon_obs, lat_obs, PRECT_obs_ANN, True, lon_mod, lat_mod, 0)
  PRECT_obs_climo_i(1,:,:) = linint2(lon_obs, lat_obs, PRECT_obs_JJA, True, lon_mod, lat_mod, 0)
  PRECT_obs_climo_i(2,:,:) = linint2(lon_obs, lat_obs, PRECT_obs_DJF, True, lon_mod, lat_mod, 0)

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
    diff = PRECT_mod_climo(i,:,:) - PRECT_obs_climo_i(i,:,:)
    diff!0 = "lat"
    diff&lat = lat_mod
    diff!1 = "lon"
    diff&lon = lon_mod

    wks = gsn_open_wks("pdf", prefix + ".climo.PRECT." + seasons(i))

    gsn_define_colormap(wks, "amwg")

    res_plot@gsnLeftString = model_atm_id + "@" + model_id
    res_plot@gsnRightString = "MEAN = " + sprintf("%4.2f", wgt_areaave(PRECT_mod_climo(i,:,:), wgt_lat, 1, 0))
    res_plot@cnLevels=(/0.2,0.5,1,2,3,4,5,6,7,8,9,10,12,14,17/)
    plot(0) = gsn_csm_contour_map_ce(wks, PRECT_mod_climo(i,:,:), res_plot)

    res_plot@gsnLeftString = "XIE-ARKIN"
    res_plot@gsnRightString = "MEAN = " + sprintf("%4.2f", wgt_areaave(PRECT_obs_climo_i(i,:,:), wgt_lat, 1, 0))
    plot(1) = gsn_csm_contour_map_ce(wks, PRECT_obs_climo_i(i,:,:), res_plot)

    res_plot@gsnLeftString = model_atm_id + "@" + model_id + " - XIE-ARKIN"
    res_plot@gsnRightString = "RMSE = "+sprintf("%4.2f", sqrt(wgt_areaave(diff^2, wgt_lat, 1, 0)))
    res_plot@cnLevels = (/-8,-6,-4,-3,-2,-1,-0.5,0,0.5,1,2,3,4,6,8/)
    plot(2) = gsn_csm_contour_map_ce(wks, diff, res_plot)

    res_panel@txString = case_id + ": " + seasons(i) + " " + start_date + " - " + end_date
    gsn_panel(wks, plot, (/3,1/), res_panel)
  end do

  ; 绘制对流性降水与格点尺度降水的比例。
  f = addfile(prefix + ".PRECC.monthly." + suffix, "r")
  PRECC_mod = f->PRECC

  ; 转换单位（TODO: 在其它地方做？）
  PRECC_mod = (/PRECC_mod*86400000/)
  PRECC_mod@units = "mm/day"

  PRECC_mod_climo = new((/num_season,num_lat_mod,num_lon_mod/), typeof(PRECC_mod))
  copy_VarCoords(PRECT_mod_climo, PRECC_mod_climo)
  tmp = clmMonTLL(PRECC_mod)
  PRECC_mod_climo(0,:,:) = dim_avg_n_Wrap(tmp, 0)
  PRECC_mod_climo(1,:,:) = rm_single_dims(month_to_season(tmp, "JJA"))
  PRECC_mod_climo(2,:,:) = rm_single_dims(month_to_season(tmp, "DJF"))

  f = addfile(prefix + ".PRECL.monthly." + suffix, "r")
  PRECL_mod = f->PRECL

  ; 转换单位（TODO: 在其它地方做？）
  PRECL_mod = (/PRECL_mod*86400000/)
  PRECL_mod@units = "mm/day"

  PRECL_mod_climo = new((/num_season,num_lat_mod,num_lon_mod/), typeof(PRECL_mod))
  copy_VarCoords(PRECT_mod_climo, PRECL_mod_climo)
  tmp = clmMonTLL(PRECL_mod)
  PRECL_mod_climo(0,:,:) = dim_avg_n_Wrap(tmp, 0)
  PRECL_mod_climo(1,:,:) = rm_single_dims(month_to_season(tmp, "JJA"))
  PRECL_mod_climo(2,:,:) = rm_single_dims(month_to_season(tmp, "DJF"))

  PRECC_mod_climo_ratio = PRECC_mod_climo/PRECT_mod_climo*100
  copy_VarCoords(PRECC_mod_climo, PRECC_mod_climo_ratio)
  PRECL_mod_climo_ratio = PRECL_mod_climo/PRECT_mod_climo*100
  copy_VarCoords(PRECL_mod_climo, PRECL_mod_climo_ratio)

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
    wks = gsn_open_wks("pdf", prefix + ".climo.PRECC_vs_PRECL." + seasons(i))

    gsn_define_colormap(wks, "amwg")

    res_plot@gsnLeftString = model_atm_id + "@" + model_id
    res_plot@gsnRightString = "convective ratio"
    res_plot@cnLevels= fspan(60, 80, 11)
    plot(0) = gsn_csm_contour_map_ce(wks, PRECC_mod_climo_ratio(i,:,:), res_plot)

    res_plot@gsnLeftString = model_atm_id + "@" + model_id
    res_plot@gsnRightString = "stratiform ratio"
    res_plot@cnLevels= fspan(20, 40, 11)
    plot(1) = gsn_csm_contour_map_ce(wks, PRECL_mod_climo_ratio(i,:,:), res_plot)

    res_panel@txString = case_id + ": " + seasons(i) + " " + start_date + " - " + end_date
    gsn_panel(wks, plot, (/2,1/), res_panel)
  end do

end
