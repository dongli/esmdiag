procedure save_to_file(var, var_name, out_path)
local f, dim_sizes, num_dim, dim, dim_names, dim_unlim, i
begin

  system("rm -rf '" + out_path + "'")
  f = addfile(out_path, "c")

  setfileoption(f, "DefineMode", True)

  dim_sizes = dimsizes(var)
  num_dim = dimsizes(dim_sizes)
  dim_names = new(num_dim, string)
  do i = 0, num_dim-1
    dim_names(i) = var!i
  end do
  dim_unlim = new(num_dim, logical)
  dim_unlim = False

  filedimdef(f, dim_names, dim_sizes, dim_unlim)

  do i = 0, num_dim-1
    dim = var&$dim_names(i)$
    filevardef(f, dim_names(i), typeof(dim), dim_names(i))
    filevarattdef(f, dim_names(i), dim)
    delete(dim)
  end do
  filevardef(f, var_name, typeof(var), getvardims(var))
  filevarattdef(f, var_name, var)

  setfileoption(f, "DefineMode", False)

  do i = 0, num_dim-1
    dim = var&$dim_names(i)$
    f->$dim_names(i)$ = (/dim/)
    delete(dim)
  end do
  f->$var_name$ = (/var/)

end
