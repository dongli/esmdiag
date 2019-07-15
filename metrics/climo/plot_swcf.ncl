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

  f = addfile(prefix + ".swcf.monthly." + suffix, "r")
  swcf_mod = f->swcf
  lat_mod = f->lat
  lon_mod = f->lon
  num_lat_mod = dimsizes(lat_mod)
  num_lon_mod = dimsizes(lon_mod)

  tmp = clmMonTLL(swcf_mod)
  swcf_mod_climo = new((/num_season,num_lat_mod,num_lon_mod/), typeof(swcf_mod))
  swcf_mod_climo!1 = "lat"
  swcf_mod_climo&lat = lat_mod
  swcf_mod_climo!2 = "lon"
  swcf_mod_climo&lon = lon_mod
  swcf_mod_climo(0,:,:) = dim_avg_n_Wrap(tmp, 0)
  swcf_mod_climo(1,:,:) = rm_single_dims(month_to_season(tmp, "JJA"))
  swcf_mod_climo(2,:,:) = rm_single_dims(month_to_season(tmp, "DJF"))
  delete(tmp)

  f = addfile("$ESMDIAG_ROOT/obs/data/CERES_ANN_climo.nc", "r")
  swcf_obs_ANN = rm_single_dims(f->SWCF)
  lat_obs = f->lat
  lon_obs = f->lon

  f = addfile("$ESMDIAG_ROOT/obs/data/CERES_JJA_climo.nc", "r")
  swcf_obs_JJA = rm_single_dims(f->SWCF)

  f = addfile("$ESMDIAG_ROOT/obs/data/CERES_DJF_climo.nc", "r")
  swcf_obs_DJF = rm_single_dims(f->SWCF)

  swcf_obs_climo_i = new((/num_season,num_lat_mod,num_lon_mod/), typeof(swcf_mod))
  copy_VarCoords(swcf_mod_climo, swcf_obs_climo_i)
  swcf_obs_climo_i(0,:,:) = linint2(lon_obs, lat_obs, swcf_obs_ANN, True, lon_mod, lat_mod, 0)
  swcf_obs_climo_i(1,:,:) = linint2(lon_obs, lat_obs, swcf_obs_JJA, True, lon_mod, lat_mod, 0)
  swcf_obs_climo_i(2,:,:) = linint2(lon_obs, lat_obs, swcf_obs_DJF, True, lon_mod, lat_mod, 0)

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
    diff = swcf_mod_climo(i,:,:) - swcf_obs_climo_i(i,:,:)
    diff!0 = "lat"
    diff&lat = lat_mod
    diff!1 = "lon"
    diff&lon = lon_mod

    wks = gsn_open_wks("pdf", prefix + ".climo.swcf." + seasons(i))

    gsn_define_colormap(wks, "amwg")

    res_plot@gsnLeftString = model_atm_id + "@" + model_id + ": " + case_id
    res_plot@gsnRightString = "MEAN = "+sprintf("%4.2f", wgt_areaave(swcf_mod_climo(i,:,:), wgt_lat, 1, 0))
    res_plot@cnLevels = (/-170,-150,-135,-120,-105,-90,-75,-60,-45,-30,-15,0,15,30,45/)
    plot(0) = gsn_csm_contour_map_ce(wks, swcf_mod_climo(i,:,:), res_plot)

    res_plot@gsnLeftString = "CERES"
    res_plot@gsnRightString = "MEAN = "+sprintf("%4.2f", wgt_areaave(swcf_obs_climo_i(i,:,:), wgt_lat, 1, 0))
    plot(1) = gsn_csm_contour_map_ce(wks, swcf_obs_climo_i(0,:,:), res_plot)

    res_plot@gsnLeftString = model_atm_id + "@" + model_id + " - CERES"
    res_plot@gsnRightString = "RMSE = "+sprintf("%4.2f", sqrt(wgt_areaave(diff^2, wgt_lat, 1, 0)))
    res_plot@cnLevels = (/-120,-100,-80,-60,-40,-20,-10,0,10,20,40,60,80,100,120/)
    plot(2) = gsn_csm_contour_map_ce(wks, diff, res_plot)

    res_panel@gsnPanelMainString = case_id + ": " + seasons(i) + " " + start_date + " - " + end_date
    gsn_panel(wks, plot, (/3,1/), res_panel)
  end do

end
