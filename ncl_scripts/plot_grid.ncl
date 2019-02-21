if (.not. isdefined("grid_file")) then
  system("echo '[Error]: Argument grid_file is not set!'")
  exit
end if
if (.not. isdefined("file_format")) then
  system("echo '[Error]: Argument file_format is not set!'")
  exit
end if

f = addfile(grid_file, "r")

wks = gsn_open_wks("pdf", systemfunc("basename " + grid_file + " .nc"))

res_map = True
res_map@gsnDraw = True
res_map@gsnFrame = False

res_grid = True
res_grid@gsMarkerSizeF = 0.000001
res_grid@gsMarkerColor = "red"

res_cell = True
res_cell@gsLineThicknessF = 0.001

map_min_lat = -90.0
if (isdefined("proj") .and. proj .eq. "NH") then
  if (.not. isdefined("map_min_lat")) then
    map_min_lat = 70.0
  end if
  res_map@gsnPolar = "NH"
  res_map@mpMinLatF = map_min_lat
end if
if (isdefined("proj") .and. proj .eq. "SH") then
  if (.not. isdefined("map_max_lat")) then
    map_max_lat = -70.0
  end if
  res_map@gsnPolar = "SH"
  res_map@mpMaxLatF = map_max_lat
end if
if (isdefined("proj") .and. proj .eq. "Satellite") then
  if (.not. isdefined("map_center_lat")) then
    map_center_lat = 45.0
  end if
  res_map@mpProjection = "Satellite"
  res_map@mpCenterLatF = map_center_lat
end if

plot = gsn_csm_map(wks, res_map)

if (file_format .eq. "SCRIP") then
	center_lon = f->grid_center_lon
	center_lat = f->grid_center_lat
	corner_lon = f->grid_corner_lon
	corner_lat = f->grid_corner_lat
	imask = f->grid_imask

	if (center_lon@units .eq. "radians") then
		center_lon = (/center_lon * get_r2d("double")/)
		center_lat = (/center_lat * get_r2d("double")/)
		corner_lon = (/corner_lon * get_r2d("double")/)
		corner_lat = (/corner_lat * get_r2d("double")/)
	end if

	gsn_polymarker(wks, plot, center_lon, center_lat, res_grid)
	
	dims = dimsizes(corner_lon)
	do i = 0, dims(0) - 1
	  if (corner_lat(i,0) .lt. map_min_lat) then
	    continue
	  end if
	  if (imask(i) .eq. 0) then
	   gsn_polygon(wks, plot, corner_lon(i,:), corner_lat(i,:), res_cell)
	  else
	    gsn_polyline(wks, plot, corner_lon(i,:), corner_lat(i,:), res_cell)
	  end if
	end do
end if
if (file_format .eq. "domain") then
	center_lon = f->xc
	center_lat = f->yc
	corner_lon = f->xv
	corner_lat = f->yv
	imask = f->mask

	gsn_polymarker(wks, plot, center_lon, center_lat, res_grid)
	
	dims = dimsizes(corner_lon)
	do j = 0, dims(0) - 1
		do i = 0, dims(1) - 1
			if (corner_lat(j,i,0) .lt. map_min_lat) then
			  continue
			end if
			if (imask(j,i) .eq. 0) then
				gsn_polygon(wks, plot, corner_lon(j,i,:), corner_lat(j,i,:), res_cell)
			else
				gsn_polyline(wks, plot, corner_lon(j,i,:), corner_lat(j,i,:), res_cell)
			end if
		end do
	end do
end if

frame(wks)
