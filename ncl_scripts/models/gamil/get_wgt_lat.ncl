function get_wgt_lat_gamil(case_id)
local f
begin

  prefix = model_id + "." + case_id

  f = addfile(prefix + ".gw.nc", "r")

  return f->gw

end
