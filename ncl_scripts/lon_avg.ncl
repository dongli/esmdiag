load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$ESMDIAG_ROOT/ncl_scripts/save_to_file.ncl"

begin

  f = addfile(var_path, "r")
  var = f->$var_name$

  num_dim = dimsizes(dimsizes(var))
  if (num_dim .eq. 3) then
    new_var = dim_avg_n_Wrap(var(time|:,lat|:,{lon|start_lon:end_lon}), 2)
  else if (num_dim .eq. 4) then
    new_var = dim_avg_n_Wrap(var(time|:,lev_p|:,lat|:,{lon|start_lon:end_lon}), 3)
  end if
  end if
  new_var@long_name = var@long_name
  new_var@units = var@units

  save_to_file(new_var, var_name, out_path)

end
