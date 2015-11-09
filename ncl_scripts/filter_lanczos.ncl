load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$SCRINIUM_ESM_DIAG_ROOT/ncl_scripts/save_to_file.ncl"

begin

  ; 输入参数：
  ;
  ;  var_path    - 待滤波的变量数据路径。
  ;  var_name    - 变量名称。
  ;  fca         - 允许通过的最低频率。
  ;  fcb         - 允许通过的最高频率。
  ;  num_wgt     - 滑动平均的跨度（必须为奇数）。
  ;  sigma       - Lanczos滤波的参数。
  ;  dims        - 对哪一维进行滤波。
  ;  out_path    - 输出的数据路径。

  f = addfile(var_path, "r")

  var = f->$var_name$

  if (.not. isdefined("num_wgt")) then
    num_wgt = 201
  end if
  if (.not. isdefined("sigma")) then
    sigma = 1.0
  end if
  if (.not. isdefined("dims")) then
    dims = 0
  end if
  wgt = filwgts_lanczos(num_wgt, 2, fca, fcb, sigma)
  new_var = wgt_runave_n_Wrap(var, wgt, 0, dims)
  copy_VarMeta(var, new_var)

  save_to_file(new_var, var_name, out_path)

end
