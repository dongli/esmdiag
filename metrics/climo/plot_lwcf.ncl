load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$SCRINIUM_ESM_DIAG_ROOT/ncl_scripts/tools.ncl"

begin

  prefix = model_id + "." + case_id
  suffix = start_date + ":" + end_date + ".nc"

  seasons = (/"ANN","JJA","DJF"/)
  num_season = dimsizes(seasons)

  f = addfile(prefix + ".LWCF.monthly." + suffix, "r")
  LWCF_mod = f->LWCF
  lat_mod = f->lat
  lon_mod = f->lon
  num_lat_mod = dimsizes(lat_mod)
  num_lon_mod = dimsizes(lon_mod)

  tmp = clmMonTLL(LWCF_mod)
  LWCF_mod_climo = new((/num_season,num_lat_mod,num_lon_mod/), typeof(LWCF_mod))
  LWCF_mod_climo!1 = "lat"
  LWCF_mod_climo&lat = lat_mod
  LWCF_mod_climo!2 = "lon"
  LWCF_mod_climo&lon = lon_mod
  LWCF_mod_climo(0,:,:) = dim_avg_n_Wrap(tmp, 0)
  LWCF_mod_climo(1,:,:) = rm_single_dims(month_to_season(tmp, "JJA"))
  LWCF_mod_climo(2,:,:) = rm_single_dims(month_to_season(tmp, "DJF"))
  delete(tmp)

  f = addfile("$SCRINIUM_ESM_DIAG_ROOT/obs/data/CERES_ANN_climo.nc", "r")
  LWCF_obs_ANN = rm_single_dims(f->LWCF)
  lat_obs = f->lat
  lon_obs = f->lon

  f = addfile("$SCRINIUM_ESM_DIAG_ROOT/obs/data/CERES_JJA_climo.nc", "r")
  LWCF_obs_JJA = rm_single_dims(f->LWCF)

  f = addfile("$SCRINIUM_ESM_DIAG_ROOT/obs/data/CERES_DJF_climo.nc", "r")
  LWCF_obs_DJF = rm_single_dims(f->LWCF)

  LWCF_obs_climo_i = new((/num_season,num_lat_mod,num_lon_mod/), typeof(LWCF_mod))
  copy_VarCoords(LWCF_mod_climo, LWCF_obs_climo_i)
  LWCF_obs_climo_i(0,:,:) = linint2(lon_obs, lat_obs, LWCF_obs_ANN, True, lon_mod, lat_mod, 0)
  LWCF_obs_climo_i(1,:,:) = linint2(lon_obs, lat_obs, LWCF_obs_JJA, True, lon_mod, lat_mod, 0)
  LWCF_obs_climo_i(2,:,:) = linint2(lon_obs, lat_obs, LWCF_obs_DJF, True, lon_mod, lat_mod, 0)

  wgt_lat = get_wgt_lat(model_id, case_id, lat_mod)

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
    diff = LWCF_mod_climo(i,:,:) - LWCF_obs_climo_i(i,:,:)
    diff!0 = "lat"
    diff&lat = lat_mod
    diff!1 = "lon"
    diff&lon = lon_mod

    wks = gsn_open_wks("pdf", prefix + ".LWCF.climo." + seasons(i))

    gsn_define_colormap(wks, "amwg")

    res_plot@gsnLeftString = model_id + ": " + case_id
    res_plot@gsnRightString = "MEAN = "+sprintf("%4.2f", wgt_areaave(LWCF_mod_climo(i,:,:), wgt_lat, 1, 0))
    res_plot@cnLevels = (/-45,-30,-20,-10,-0,10,20,30,40,50,60,70,85,100,115/)
    plot(0) = gsn_csm_contour_map_ce(wks, LWCF_mod_climo(i,:,:), res_plot)

    res_plot@gsnLeftString = "CERES-EBAF"
    res_plot@gsnRightString = "MEAN = "+sprintf("%4.2f", wgt_areaave(LWCF_obs_climo_i(i,:,:), wgt_lat, 1, 0))
    plot(1) = gsn_csm_contour_map_ce(wks, LWCF_obs_climo_i(0,:,:), res_plot)

    res_plot@gsnLeftString = model_id + " - CERES"
    res_plot@gsnRightString = "RMSE = "+sprintf("%4.2f", sqrt(wgt_areaave(diff^2, wgt_lat, 1, 0)))
    res_plot@cnLevels = (/-80,-60,-40,-30,-20,-10,-5,0,5,10,20,30,40,60,80/)
    plot(2) = gsn_csm_contour_map_ce(wks, diff, res_plot)

    res_panel@txString = case_id + ": " + seasons(i) + " " + start_date + " - " + end_date
    gsn_panel(wks, plot, (/3,1/), res_panel)
  end do

end
