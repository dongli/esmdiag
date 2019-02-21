if (.not. isdefined("res")) then
	system("echo '[Error]: Argument res is not set!'")
	exit
end if

if (res .eq. "1x1") then
	dlon = 1.0
	dlat = 1.0
	num_lon = 360
	num_lat = 180
end if

lon = fspan(0.0, 360.0 - dlon, 360)
lat = fspan(-90.0 + dlat * 0.5, 90.0 - dlat * 0.5, num_lat)

rectilinear_to_SCRIP("latlon_" + res + ".nc", lat, lon, False)
