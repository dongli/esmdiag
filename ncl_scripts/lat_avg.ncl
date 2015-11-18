load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$SCRINIUM_ESM_DIAG_ROOT/ncl_scripts/save_to_file.ncl"

begin

  f = addfile(var_path, "r")
  var = f->$var_name$

  if (.not. isdefined("use_wgt_lat")) then
    use_wgt_lat = True
  end if

  wgt_lat = cos(0.017459*f->lat({start_lat:end_lat}))
  if (.not. use_wgt_lat) then
    wgt_lat = 1.0
  end if

  opt = 0

  num_dim = dimsizes(dimsizes(var))
  if (num_dim .eq. 3) then
    new_var = dim_avg_wgt_n_Wrap(var(time|:,{lat|start_lat:end_lat},lon|:), wgt_lat, opt, 1)
  else if (num_dim .eq. 4) then
    new_var = dim_avg_wgt_n_Wrap(var(time|:,lev_p|:,{lat|start_lat:end_lat},lon|:), wgt_lat, opt, 2)
  end if
  end if
  new_var@long_name = var@long_name
  new_var@units = var@units

  save_to_file(new_var, var_name, out_path)

end
