load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ESMDIAG_ROOT/ncl_scripts/tools.ncl"

begin

  prefix = model_ocn_id + "." + case_id
  suffix = start_date + ":" + end_date + ".nc"

  seasons = (/"ANN","JJA","DJF"/)
  num_season = dimsizes(seasons)

  f = addfile(prefix + ".ss.monthly.regrid_latlon_1x1." + suffix, "r")
  ss_mod = f->ss
	lev_mod = f->lev
  lat_mod = f->lat
  lon_mod = f->lon
	num_lev_mod = dimsizes(lev_mod)
  num_lat_mod = dimsizes(lat_mod)
  num_lon_mod = dimsizes(lon_mod)

  tmp = clmMonTLLL(ss_mod)
  ss_mod_climo = new((/num_season,num_lev_mod,num_lat_mod,num_lon_mod/), typeof(ss_mod))
	ss_mod_climo!1 = "lev"
	ss_mod_climo&lev = lev_mod
  ss_mod_climo!2 = "lat"
  ss_mod_climo&lat = lat_mod
  ss_mod_climo!3 = "lon"
  ss_mod_climo&lon = lon_mod
  ss_mod_climo(0,:,:,:) = dim_avg_n_Wrap(tmp, 0)
  ss_mod_climo(1,:,:,:) = rm_single_dims(month_to_season(tmp, "JJA"))
  ss_mod_climo(2,:,:,:) = rm_single_dims(month_to_season(tmp, "DJF"))
  delete(tmp)

	; Zonal average
	za_ss_mod = dim_avg_n_Wrap(ss_mod, 3)

  tmp = clmMonTLL(za_ss_mod)
  za_ss_mod_climo = new((/num_season,num_lev_mod,num_lat_mod/), typeof(za_ss_mod))
  za_ss_mod_climo!1 = "lev"
  za_ss_mod_climo&lev = lev_mod
  za_ss_mod_climo!2 = "lat"
  za_ss_mod_climo&lat = lat_mod
  za_ss_mod_climo(0,:,:) = dim_avg_n_Wrap(tmp, 0)
  za_ss_mod_climo(1,:,:) = rm_single_dims(month_to_season(tmp, "JJA"))
  za_ss_mod_climo(2,:,:) = rm_single_dims(month_to_season(tmp, "DJF"))
  delete(tmp)

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

  plot = new(2, graphic)

  do i = 0, num_season - 1
    wks = gsn_open_wks("pdf", prefix + ".climo.salinity." + seasons(i))

    gsn_define_colormap(wks, "GMT_panoply")

    res_plot@gsnLeftString = model_ocn_id + "@" + model_id + ": " + case_id
    res_plot@cnLevels = fspan(10.0, 50.0, 15)

    plot(0) = gsn_csm_contour(wks, za_ss_mod_climo(i,:,:), res_plot)

		plot(1) = gsn_csm_contour_map_ce(wks, ss_mod_climo(i,0,:,:), res_plot)

    res_panel@gsnPanelMainString = case_id + ": " + seasons(i) + " " + start_date + " - " + end_date
    gsn_panel(wks, plot, (/2,1/), res_panel)
  end do

end
