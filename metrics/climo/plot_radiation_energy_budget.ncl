load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ESMDIAG_ROOT/ncl_scripts/tools.ncl"

begin

  prefix = model_atm_id + "." + case_id
  suffix = start_date + ":" + end_date + ".nc"

  f = addfile(prefix + ".FLUTOA.monthly." + suffix, "r")
  FLUTOA = f->FLUTOA

  f = addfile(prefix + ".FSNTOA.monthly." + suffix, "r")
  FSNTOA = f->FSNTOA

  lat = f->lat
  lon = f->lon

  wgt_lat = get_wgt_lat(model_atm_id, case_id, lat)

  diff = FSNTOA - FLUTOA
  diff_climo = dim_avg_n_Wrap(diff, 0)
  diff_climo!0 = "lat"
  diff_climo&lat = lat
  diff_climo!1 = "lon"
  diff_climo&lon = lon

  wks = gsn_open_wks("pdf", prefix + ".climo.radiation_energy_budget.")

  gsn_define_colormap(wks, "amwg")

  res_plot = common_plot_settings()
  res_plot@cnLinesOn = False
  res_plot@cnFillOn = True
  res_plot@mpLandFillColor = "white"
  res_plot@gsnLeftString = "FSNTOA - FLUTOA (" + FSNTOA@units + ")"
  res_plot@gsnRightString = "mean: " + sprintf("%5.2f", wgt_areaave(diff_climo, wgt_lat, 1, 0))
  res_plot@cnLevelSelectionMode = "ExplicitLevels"
  res_plot@cnLevels = fspan(-120, 80, 11)
  res_plot@pmLabelBarOrthgonalPosF = -0.5

  plot = gsn_csm_contour_map_ce(wks, diff_climo, res_plot)

  draw(plot)
  frame(wks)

end
