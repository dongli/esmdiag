load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$ESMDIAG_ROOT/ncl_scripts/save_to_file.ncl"

begin

	f = addfile(var_path, "r")

	var = f->$var_name$

	; Generate regrid weight file if not exist.
	wgt_path = model_id + "." + dst_grid + ".wgt.nc"
	if (.not. isfilepresent(wgt_path)) then
		opt = True
		opt@InterpMethod = regrid_type

		ESMF_regrid_gen_weights(src_grid_file, dst_grid_file, wgt_path, opt)
	end if

	regridded_var = ESMF_regrid_with_weights(var, wgt_path, False)

	save_to_file(regridded_var, var_name, out_path)

end
