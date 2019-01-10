load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$ESMDIAG_ROOT/ncl_scripts/save_to_file.ncl"

begin

  ; 输入参数：
  ;
  ;  var_path    - 待滤波的变量数据路径。
  ;  var_name    - 变量名称。
  ;  fca         - 允许通过的最低频率。
  ;  fcb         - 允许通过的最高频率。
  ;  order       - 滤波器的阶数（参见bw_bandpass_filter函数）。
  ;  remove_mean - 去除平均值。
  ;  dims        - 对哪些维进行滤波。
  ;  out_path    - 输出的数据路径。

  f = addfile(var_path, "r")

  var = f->$var_name$

  opt = True
  if (isdefined("order")) then
    opt@m = order
  end if
  if (isdefined("remove_mean")) then
    opt@remove_mean = remove_mean
  else
    opt@remove_mean = False
  end if
  if (.not. isdefined("dims")) then
    dims = 0
  end if
  new_var = bw_bandpass_filter(var, fca, fcb, opt, dims)
  copy_VarMeta(var, new_var)

  save_to_file(new_var, var_name, out_path)

end
