load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$SCRINIUM_ESM_DIAG_ROOT/ncl_scripts/tools.ncl"

prefix = model_id + "." + case_id
suffix = start_date + ":" + end_date + ".nc"

seasons = (/"ANN","JJA","DJF"/)
num_season = dimsizes(seasons)

res_plot = common_plot_settings()
res_plot@cnLinesOn = False
res_plot@cnFillOn = True
res_plot@tmLabelAutoStride = True
res_plot@tiYAxisOn = False
res_plot@tmYRMode = "Automatic"
res_plot@cnLevelSelectionMode = "ExplicitLevels"

res_panel = common_panel_settings()

procedure plot_T()
begin

  lev_tag = "1000:925:850:775:700:600:500:400:300:250:200:150:100:70:50:30:10"

  f = addfile(prefix + ".T.monthly.vinterp" + lev_tag + "." + suffix, "r")
  T_mod_zonal_mean = zonalAve(f->T)

  lev = f->lev_p
  num_lev = dimsizes(lev)
  lat_mod = f->lat
  num_lat_mod = dimsizes(lat_mod)

  tmp = clmMonTLL(T_mod_zonal_mean)
  T_mod_zonal_mean_climo = new((/num_season,num_lev,num_lat_mod/), typeof(T_mod_zonal_mean))
  T_mod_zonal_mean_climo!1 = "lev"
  T_mod_zonal_mean_climo&lev = lev
  T_mod_zonal_mean_climo!2 = "lat"
  T_mod_zonal_mean_climo&lat = lat_mod
  T_mod_zonal_mean_climo(0,:,:) = (/dim_avg_n(tmp, 0)/)
  T_mod_zonal_mean_climo(1,:,:) = (/rm_single_dims(month_to_season(tmp, "JJA"))/)
  T_mod_zonal_mean_climo(2,:,:) = (/rm_single_dims(month_to_season(tmp, "DJF"))/)
 
  f = addfile("$SCRINIUM_ESM_DIAG_ROOT/obs/data/ECMWF_ANN_climo.nc", "r")
  T_obs_zonal_mean_ANN = rm_single_dims(zonalAve(f->T))
  lat_obs = f->lat

  f = addfile("$SCRINIUM_ESM_DIAG_ROOT/obs/data/ECMWF_JJA_climo.nc", "r")
  T_obs_zonal_mean_JJA = rm_single_dims(zonalAve(f->T))

  f = addfile("$SCRINIUM_ESM_DIAG_ROOT/obs/data/ECMWF_DJF_climo.nc", "r")
  T_obs_zonal_mean_DJF = rm_single_dims(zonalAve(f->T))

  ; TODO: 比较两种网格哪个密一些，将密的插值到疏的。
  T_obs_zonal_mean_climo_i = new((/num_season,num_lev,num_lat_mod/), typeof(T_obs_zonal_mean_ANN))
  copy_VarCoords(T_mod_zonal_mean_climo, T_obs_zonal_mean_climo_i)
  T_obs_zonal_mean_climo_i(0,:,:) = linint1_n(lat_obs, T_obs_zonal_mean_ANN, False, lat_mod, 0, 1)
  T_obs_zonal_mean_climo_i(1,:,:) = linint1_n(lat_obs, T_obs_zonal_mean_JJA, False, lat_mod, 0, 1)
  T_obs_zonal_mean_climo_i(2,:,:) = linint1_n(lat_obs, T_obs_zonal_mean_DJF, False, lat_mod, 0, 1)

  plot = new((/3/), graphic)

  do i = 0, num_season - 1
    diff = T_mod_zonal_mean_climo(i,:,:) - T_obs_zonal_mean_climo_i(i,:,:)
    diff!0 = "lev"
    diff&lev = lev
    diff!1 = "lat"
    diff&lat = lat_mod

    wks = gsn_open_wks("pdf", prefix + ".T.zonal_mean.climo." + seasons(i))

    gsn_define_colormap(wks, "amwg")

    res_plot@gsnRightString = "temperature"

    res_plot@gsnLeftString = model_id
    res_plot@cnLevels = (/180,185,190,200,210,220,230,240,250,260,270,280,290,295,300/)
    plot(0) = gsn_csm_pres_hgt(wks, T_mod_zonal_mean_climo(i,:,:), res_plot)

    res_plot@gsnLeftString = "ECMWF"
    plot(1) = gsn_csm_pres_hgt(wks, T_obs_zonal_mean_climo_i(i,:,:), res_plot)

    res_plot@gsnLeftString = model_id + " - ECMWF"
    res_plot@cnLevels = (/-9,-7,-5,-4,-3,-2,-1,0,1,2,3,4,5,7,9/)
    plot(2) = gsn_csm_pres_hgt(wks, diff, res_plot)

    res_panel@txString = case_id + ": " + seasons(i) + " " + start_date + " - " + end_date
    gsn_panel(wks, plot, (/1,3/), res_panel)
  end do

end

procedure plot_U()
begin

  lev_tag = "1000:925:850:775:700:600:500:400:300:250:200:150:100:70:50:30:10"

  f = addfile(prefix + ".U.monthly.vinterp" + lev_tag + "." + suffix, "r")
  U_mod_zonal_mean = zonalAve(f->U)

  lev = f->lev_p
  num_lev = dimsizes(lev)
  lat_mod = f->lat
  num_lat_mod = dimsizes(lat_mod)

  tmp = clmMonTLL(U_mod_zonal_mean)
  U_mod_zonal_mean_climo = new((/num_season,num_lev,num_lat_mod/), typeof(U_mod_zonal_mean))
  U_mod_zonal_mean_climo!1 = "lev"
  U_mod_zonal_mean_climo&lev = lev
  U_mod_zonal_mean_climo!2 = "lat"
  U_mod_zonal_mean_climo&lat = lat_mod
  U_mod_zonal_mean_climo(0,:,:) = (/dim_avg_n(tmp, 0)/)
  U_mod_zonal_mean_climo(1,:,:) = (/rm_single_dims(month_to_season(tmp, "JJA"))/)
  U_mod_zonal_mean_climo(2,:,:) = (/rm_single_dims(month_to_season(tmp, "DJF"))/)

  f = addfile("$SCRINIUM_ESM_DIAG_ROOT/obs/data/ECMWF_ANN_climo.nc", "r")
  U_obs_zonal_mean_ANN = rm_single_dims(zonalAve(f->U))
  lat_obs = f->lat

  f = addfile("$SCRINIUM_ESM_DIAG_ROOT/obs/data/ECMWF_JJA_climo.nc", "r")
  U_obs_zonal_mean_JJA = rm_single_dims(zonalAve(f->U))

  f = addfile("$SCRINIUM_ESM_DIAG_ROOT/obs/data/ECMWF_DJF_climo.nc", "r")
  U_obs_zonal_mean_DJF = rm_single_dims(zonalAve(f->U))

  ; TODO: 比较两种网格哪个密一些，将密的插值到疏的。
  U_obs_zonal_mean_climo_i = new((/num_season,num_lev,num_lat_mod/), typeof(U_obs_zonal_mean_ANN))
  copy_VarCoords(U_mod_zonal_mean_climo, U_obs_zonal_mean_climo_i)
  U_obs_zonal_mean_climo_i(0,:,:) = linint1_n(lat_obs, U_obs_zonal_mean_ANN, False, lat_mod, 0, 1)
  U_obs_zonal_mean_climo_i(1,:,:) = linint1_n(lat_obs, U_obs_zonal_mean_JJA, False, lat_mod, 0, 1)
  U_obs_zonal_mean_climo_i(2,:,:) = linint1_n(lat_obs, U_obs_zonal_mean_DJF, False, lat_mod, 0, 1)

  plot = new((/3/), graphic)

  do i = 0, num_season - 1
    diff = U_mod_zonal_mean_climo(i,:,:) - U_obs_zonal_mean_climo_i(i,:,:)
    diff!0 = "lev"
    diff&lev = lev
    diff!1 = "lat"
    diff&lat = lat_mod

    wks = gsn_open_wks("pdf", prefix + ".U.zonal_mean.climo." + seasons(i))

    gsn_define_colormap(wks, "amwg")

    res_plot@gsnRightString = "zonal wind"

    res_plot@gsnLeftString = model_id
    res_plot@cnLevels = (/-20,-15,-10,-5,0,5,10,15,20,25,30,40,50,60,70/)
    plot(0) = gsn_csm_pres_hgt(wks, U_mod_zonal_mean_climo(i,:,:), res_plot)

    res_plot@gsnLeftString = "ECMWF"
    plot(1) = gsn_csm_pres_hgt(wks, U_obs_zonal_mean_climo_i(i,:,:), res_plot)

    res_plot@gsnLeftString = model_id + " - ECMWF"
    res_plot@cnLevels = (/-18,-15,-12,-9,-6,-3,-1,0,1,3,6,9,12,15,18/)
    plot(2) = gsn_csm_pres_hgt(wks, diff, res_plot)

    res_panel@txString = case_id + ": " + seasons(i) + " " + start_date + " - " + end_date
    gsn_panel(wks, plot, (/1,3/), res_panel)
  end do

end

procedure plot_Q()
begin

  lev_tag = "1000:925:850:775:700:600:500:400:300"

  f = addfile(prefix + ".Q.monthly.vinterp" + lev_tag + "." + suffix, "r")
  Q_mod_zonal_mean = zonalAve(f->Q)

  lev = f->lev_p
  num_lev = dimsizes(lev)
  lat_mod = f->lat
  num_lat_mod = dimsizes(lat_mod)

  ; 转换比湿的单位kg/kg -> g/kg。
  Q_mod_zonal_mean = (/1000*Q_mod_zonal_mean/)
  Q_mod_zonal_mean@units = "g/kg"

  tmp = clmMonTLL(Q_mod_zonal_mean)
  Q_mod_zonal_mean_climo = new((/num_season,num_lev,num_lat_mod/), typeof(Q_mod_zonal_mean))
  Q_mod_zonal_mean_climo!1 = "lev"
  Q_mod_zonal_mean_climo&lev = lev
  Q_mod_zonal_mean_climo!2 = "lat"
  Q_mod_zonal_mean_climo&lat = lat_mod
  Q_mod_zonal_mean_climo(0,:,:) = (/dim_avg_n(tmp, 0)/)
  Q_mod_zonal_mean_climo(1,:,:) = (/rm_single_dims(month_to_season(tmp, "JJA"))/)
  Q_mod_zonal_mean_climo(2,:,:) = (/rm_single_dims(month_to_season(tmp, "DJF"))/)
  delete(tmp)

  f = addfile("$SCRINIUM_ESM_DIAG_ROOT/obs/data/ECMWF_ANN_climo.nc", "r")
  Q_obs_zonal_mean_ANN = rm_single_dims(zonalAve(f->SHUM))
  lat_obs = f->lat

  f = addfile("$SCRINIUM_ESM_DIAG_ROOT/obs/data/ECMWF_JJA_climo.nc", "r")
  Q_obs_zonal_mean_JJA = rm_single_dims(zonalAve(f->SHUM))

  f = addfile("$SCRINIUM_ESM_DIAG_ROOT/obs/data/ECMWF_DJF_climo.nc", "r")
  Q_obs_zonal_mean_DJF = rm_single_dims(zonalAve(f->SHUM))

  ; TODO: 比较两种网格哪个密一些，将密的插值到疏的。
  Q_obs_zonal_mean_climo_i = new((/num_season,num_lev,num_lat_mod/), typeof(Q_obs_zonal_mean_ANN))
  copy_VarCoords(Q_mod_zonal_mean_climo, Q_obs_zonal_mean_climo_i)
  Q_obs_zonal_mean_climo_i(0,:,:) = linint1_n(lat_obs, Q_obs_zonal_mean_ANN, False, lat_mod, 0, 1)
  Q_obs_zonal_mean_climo_i(1,:,:) = linint1_n(lat_obs, Q_obs_zonal_mean_JJA, False, lat_mod, 0, 1)
  Q_obs_zonal_mean_climo_i(2,:,:) = linint1_n(lat_obs, Q_obs_zonal_mean_DJF, False, lat_mod, 0, 1)

  plot = new((/3/), graphic)

  do i = 0, num_season - 1
    diff = Q_mod_zonal_mean_climo(i,:,:) - Q_obs_zonal_mean_climo_i(i,:,:)
    diff!0 = "lev"
    diff&lev = lev
    diff!1 = "lat"
    diff&lat = lat_mod

    wks = gsn_open_wks("pdf", prefix + ".Q.zonal_mean.climo." + seasons(i))

    gsn_define_colormap(wks, "amwg")

    res_plot@gsnRightString = "specific humidity"

    res_plot@gsnLeftString = model_id
    res_plot@cnLevels = (/1,2,3,4,5,6,7,8,9,10,11,12,13,14,15/)
    plot(0) = gsn_csm_pres_hgt(wks, Q_mod_zonal_mean_climo(i,:,:), res_plot)

    res_plot@gsnLeftString = "ECMWF"
    plot(1) = gsn_csm_pres_hgt(wks, Q_obs_zonal_mean_climo_i(i,:,:), res_plot)

    res_plot@gsnLeftString = model_id + " - ECMWF"
    delete(res_plot@cnLevels)
    res_plot@cnLevels = (/-1.8,-1.5,-1.2,-.9,-.6,-.3,-.1,0,.1,.3,.6,.9,1.2,1.5,1.8/)
    plot(2) = gsn_csm_pres_hgt(wks, diff, res_plot)

    res_panel@txString = case_id + ": " + seasons(i) + " " + start_date + " - " + end_date
    gsn_panel(wks, plot, (/3,3/), res_panel)
  end do

end

begin

  plot_T()
  plot_U()
  plot_Q()

end

