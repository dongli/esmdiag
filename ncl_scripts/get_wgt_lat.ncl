function get_wgt_lat(model_id, case_id, lat)
begin

  if (str_lower(model_id) .eq. "gamil") then
    tmp = get_wgt_lat_gamil(case_id)
  end if
  if (.not. isdefined("tmp")) then
    tmp = cos(lat*atan(1.0)/45.0)
  end if

  return tmp({lat})

end
