load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ESMDIAG_ROOT/ncl_scripts/tools.ncl"

begin

  prefix = model_ice_id + "." + case_id
  suffix = start_date + ":" + end_date + ".nc"

  seasons = (/"ANN","JJA","DJF"/)
  num_season = dimsizes(seasons)

  f = addfile(prefix + ".aice.monthly." + suffix, "r")
  aice_mod = f->aice
  tlon2d = f->TLON
  tlat2d = f->TLAT
  aice_mod@lon2d = tlon2d
  aice_mod@lat2d = tlat2d

  tgrid_dims = dimsizes(tlon2d)

  tmp = clmMonTLL(aice_mod)
  aice_mod_climo = new((/num_season,tgrid_dims(0),tgrid_dims(1)/), typeof(aice_mod))
  aice_mod_climo@lon2d = tlon2d
  aice_mod_climo@lat2d = tlat2d
  do i = 0, num_season - 1
    if (seasons(i) .eq. "ANN") then
      aice_mod_climo(0,:,:) = dim_avg_n_Wrap(tmp, 0)
    else
      aice_mod_climo(1,:,:) = rm_single_dims(month_to_season(tmp, seasons(i)))
    end if
  end do
  delete(tmp)

  res_plot = common_plot_settings()
  res_plot@cnLinesOn = False
  res_plot@cnFillOn = True
  res_plot@mpLandFillColor = "white"
  res_plot@lbLabelStride = 2
  res_plot@tmLabelAutoStride = True
  res_plot@lbOrientation = "vertical"
  res_plot@cnLevelSelectionMode = "ManualLevels"
  res_plot@cnMinLevelValF = 5.0
  res_plot@cnMaxLevelValF = 95.0
  res_plot@cnLevelSpacingF = 5.0
  res_plot@gsnLeftString = model_ice_id + "@" + model_id + ": " + case_id

  res_panel = common_panel_settings()

  plot = new(2, graphic)

  do i = 0, num_season - 1
    wks = gsn_open_wks("pdf", prefix + ".climo.aice." + seasons(i))

    gsn_define_colormap(wks, "amwg")

    res_plot@gsnPolar = "NH"
    res_plot@mpMinLatF = 40.0
    delete(res_plot@mpMaxLatF)
    plot(0) = gsn_csm_contour_map_polar(wks, aice_mod_climo(i,:,:), res_plot)

    res_plot@gsnPolar = "SH"
    res_plot@mpMaxLatF = -40.0
    delete(res_plot@mpMinLatF)
    plot(1) = gsn_csm_contour_map_polar(wks, aice_mod_climo(i,:,:), res_plot)

    res_panel@txString = case_id + ": " + seasons(i) + " " + start_date + " - " + end_date
    gsn_panel(wks, plot, (/1,2/), res_panel)
  end do

end
