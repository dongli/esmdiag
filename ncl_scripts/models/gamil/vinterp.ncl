load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$SCRINIUM_ESM_DIAG_ROOT/ncl_scripts/save_to_file.ncl"

begin

  ; 输入参数：
  ;
  ;  ps_path     - 地面气压数据路径。
  ;  var_path    - 待插值变量数据路径。
  ;  var_name    - 变量名称。
  ;  plevs       - 需要插值到哪些等压面上。
  ;  interp_type - 插值类型（参见vinth2p函数）。
  ;  extrap      - 是否使用外插（参见vinth2p函数）。
  ;  out_path    - 输出的数据路径。

  plevs@long_name = "interpolated barotropic levels"
  plevs@units = "hPa"

  ; 获取地面气压数据。
  f = addfile(ps_path, "r")

  ps = f->PS

  delete(f)

  ; 获取三维变量数据。
  f = addfile(var_path, "w")

  time = f->time
  lat = f->lat
  lon = f->lon
  time_bnds = f->time_bnds

  num_time = dimsizes(time)
  num_lat  = dimsizes(lat)
  num_lon  = dimsizes(lon)

  var = f->$var_name$

  ; 由于GAMIL目前采用经典sigma气压坐标，我们需要设置等价的混合坐标参数，以使用vinth2p函数。
  p0 = 2.194
  hybm = f->lev
  hyam = 1 - hybm

  ; 调用vinth2p函数插值。
  new_var = vinth2p(var, hyam, hybm, plevs, ps, interp_type, p0, 1, extrap)
  new_var@long_name = var@long_name
  new_var@units = var@units

  save_to_file(new_var, var_name, out_path)

end
