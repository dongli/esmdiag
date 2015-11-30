load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$SCRINIUM_ESM_DIAG_ROOT/ncl_scripts/save_to_file.ncl"

begin

  f = addfile(var_path, "r")
  var = f->$var_name$

  if (.not. isdefined("dim")) then
    dim = 0
  end if

  new_var = dtrend_n(var, True, dim)
  copy_VarCoords(var, new_var)
  new_var@long_name = var@long_name + " detrended"
  new_var@units = var@units

  save_to_file(new_var, var_name, out_path)

end
