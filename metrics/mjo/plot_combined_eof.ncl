load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 

load "$ESMDIAG_ROOT/ncl_scripts/tools.ncl"

begin

  prefix = model_id + "." + case_id
  suffix = start_date + ":" + end_date + ".nc"

  f = addfile(prefix + ".OLR.daily.anomaly.filtered." + suffix, "r")
  OLR = dim_avg_n_Wrap(f->OLR(time|:,{lat|-15:15},lon|:), 1)

  f = addfile(prefix + ".U.daily.anomaly.vinterp850:200.filtered." + suffix, "r")
  U850 = dim_avg_n_Wrap(f->U(time|:,{lev_p|850},{lat|-15:15},lon|:), 1)
  U200 = dim_avg_n_Wrap(f->U(time|:,{lev_p|200},{lat|-15:15},lon|:), 1)

  num_time = dimsizes(f->time)
  num_lon  = dimsizes(f->lon)
  lon      = f->lon
  time     = f->time

  OLR  = dim_rmvmean_n( OLR, 0)
  U850 = dim_rmvmean_n(U850, 0)
  U200 = dim_rmvmean_n(U200, 0)

  OLR_variance  = dim_variance_n_Wrap( OLR, 0)
  U850_variance = dim_variance_n_Wrap(U850, 0)
  U200_variance = dim_variance_n_Wrap(U200, 0)

  OLR_variance_zavg  = dim_avg_n_Wrap( OLR_variance, 0)
  U850_variance_zavg = dim_avg_n_Wrap(U850_variance, 0)
  U200_variance_zavg = dim_avg_n_Wrap(U200_variance, 0)

  ; 将多个变量合为一个标准化的变量。
  OLR  =  OLR/sqrt( OLR_variance_zavg)
  U850 = U850/sqrt(U850_variance_zavg)
  U200 = U200/sqrt(U200_variance_zavg)

  cdata = new((/3*num_lon,num_time/), typeof(OLR), getFillValue(OLR))
  do i = 0, num_lon-1
    cdata(i          ,:) = (/ OLR(:,i)/)
    cdata(i+  num_lon,:) = (/U850(:,i)/)
    cdata(i+2*num_lon,:) = (/U200(:,i)/)
  end do

  ; 计算联合EOF。
  num_eof = 2
  eof_cdata = eofunc(cdata, num_eof, False)
  eof_ts_cdata = eofunc_ts(cdata, eof_cdata, False)

  ; 为了清楚起见，将各变量提取出来。
  var = (/"OLR","U850","U200"/)
  ceof = new((/dimsizes(var),num_eof,num_lon/), typeof(cdata), getFillValue(cdata))
  do i = 0, num_eof-1
    ceof(0,i,:) = eof_cdata(i,        0:  num_lon-1)
    ceof(1,i,:) = eof_cdata(i,  num_lon:2*num_lon-1)
    ceof(2,i,:) = eof_cdata(i,2*num_lon:)
  end do
  ceof!0 = "var"
  ceof!1 = "eof"
  ceof!2 = "lon"
  ceof&var = var
  ceof&lon = lon

  ceof_ts = new((/dimsizes(var),num_eof,num_time/), typeof(cdata), getFillValue(cdata))
  ceof_ts(0,:,:) = eofunc_ts_Wrap( OLR(lon|:,time|:), ceof(0,:,:), False)
  ceof_ts(1,:,:) = eofunc_ts_Wrap(U850(lon|:,time|:), ceof(1,:,:), False)
  ceof_ts(2,:,:) = eofunc_ts_Wrap(U200(lon|:,time|:), ceof(2,:,:), False)

  ; 计算方差贡献比例。
  pcv_eof_OLR  = new(num_eof, typeof(ceof))
  pcv_eof_U850 = new(num_eof, typeof(ceof))
  pcv_eof_U200 = new(num_eof, typeof(ceof))
  do i = 0, num_eof-1
    pcv_eof_OLR(i)  = avg((ceof(0,i,:)*sqrt(ceof@eval(i)))^2)*100
    pcv_eof_U850(i) = avg((ceof(1,i,:)*sqrt(ceof@eval(i)))^2)*100
    pcv_eof_U200(i) = avg((ceof(2,i,:)*sqrt(ceof@eval(i)))^2)*100
  end do

  ; 改变符号。
  imax_850   = maxind(ceof(1,0,:))     ; max u850 eof 1 
  imin_850   = minind(ceof(1,0,:))     ; min     

  imax_200   = maxind(ceof(1,1,:))     ; max u200 eof 2
  imin_200   = minind(ceof(1,1,:))     ; min

  lonmax_850 = ceof&lon(imax_850)      ; longitude of max value
  lonmax_200 = ceof&lon(imax_200)

  if (lonmax_850.lt.50 .or. lonmax_850.gt.120) then
    ceof(:,0,:)       = -ceof(:,0,:)         
    ceof_ts(:,0,:)    = -ceof_ts(:,0,:)  
    eof_cdata(0,:)    = -eof_cdata(0,:)
    eof_ts_cdata(0,:) = -eof_ts_cdata(0,:)
  end if

  if (lonmax_200.lt.90 .or. lonmax_200.gt.150) then
    ceof(:,1,:)       = -ceof(:,1,:)         
    ceof_ts(:,1,:)    = -ceof_ts(:,1,:)  
    eof_cdata(1,:)    = -eof_cdata(1,:)
    eof_ts_cdata(1,:) = -eof_ts_cdata(1,:)
  end if

  ; 计算各变量时间序列的交叉相关。
  ccr_OLR_U850  = escorc(ceof_ts(0,:,:), ceof_ts(1,:,:))
  ccr_OLR_U200  = escorc(ceof_ts(0,:,:), ceof_ts(2,:,:))
  ccr_U850_U200 = escorc(ceof_ts(1,:,:), ceof_ts(2,:,:))

  ; 计算多变量EOF的交叉相关。EOF1 vs EOF2
  mxlag = 25
  rlag_01 = esccr(eof_ts_cdata(0,:), eof_ts_cdata(1,:), mxlag)
  rlag_10 = esccr(eof_ts_cdata(1,:), eof_ts_cdata(0,:), mxlag)
  ccr_12  = new((/2*mxlag + 1/), float)

  ccr_12(mxlag:)    = rlag_10(0:mxlag)   
  ccr_12(0:mxlag)   = rlag_01(::-1)

  ; 标准化多变量EOF的第1和第2分量的时间序列。
  eof_ts_cdata(0,:) = eof_ts_cdata(0,:)/stddev(eof_ts_cdata(0,:))
  eof_ts_cdata(1,:) = eof_ts_cdata(1,:)/stddev(eof_ts_cdata(1,:))

  mjo_ts_index     = eof_ts_cdata(0,:)^2 + eof_ts_cdata(1,:)^2
  mjo_ts_index_smt = runave(mjo_ts_index, 91, 0)

  ; 输出到文件。
  mjo_ts_index!0         = "time"
  mjo_ts_index&time      = time
  mjo_ts_index@long_name = "MJO PC index"
  mjo_ts_index@info      = "PC^2 + PC^2"

  PC1           = eof_ts_cdata(0,:)
  PC1!0         = "time"
  PC1&time      = time
  PC1@long_name = "PC1"
  PC1@info      = "PC1/stddev(PC1)"

  PC2           = eof_ts_cdata(1,:)
  PC2!0         = "time"
  PC2&time      = time
  PC2@long_name = "PC2"
  PC2@info      = "PC2/stddev(PC2)"

  file_name = prefix + ".mjo_pc_index." + suffix
  system("/bin/rm -f " + file_name)
  f = addfile(file_name, "c")

  filedimdef(f, "time", -1, True)

  f->MJO_INDEX = mjo_ts_index
  f->PC1       = PC1
  f->PC2       = PC2

  ; 绘图。
  wks = gsn_open_wks("pdf", prefix + ".mjo.index")

  plot = new(3, graphic)

  ; 绘制多变量EOF图。
  res1                   = common_plot_settings()
  res1@gsnScale          = True
  res1@vpHeightF         = 0.40
  res1@vpWidthF          = 0.85
  res1@vpXF              = 0.10
  res1@vpYF              = 0.75
  res1@xyLineThicknesses = (/      2,    2,     2/)
  res1@xyLineColors      = (/"black","red","blue"/)
  res1@gsnYRefLine       = 0.0

  res1@pmLegendSide           = "Top"
  res1@pmLegendParallelPosF   = 0.86
  res1@pmLegendOrthogonalPosF = -0.50
  res1@pmLegendWidthF         = 0.15
  res1@pmLegendHeightF        = 0.15
  res1@lgLabelFontHeightF     = 0.0175

  do i = 0, num_eof-1
    res1@xyExplicitLegendLabels = (/"U200: " + sprintf("%4.1f", pcv_eof_U200(i)) + "%", \
                                    "U850: " + sprintf("%4.1f", pcv_eof_U850(i)) + "%", \
                                    "OLR:  " + sprintf("%4.1f", pcv_eof_OLR(i))  + "%"/)
    res1@gsnLeftString = "EOF " + (i + 1)
    res1@gsnRightString = sprintf("%3.1f", ceof@pcvar(i)) + "%"
    plot(i) = gsn_csm_xy(wks, lon, ceof(:,i,:), res1)
  end do

  gsn_panel(wks, plot(0:1), (/2,1/), False)

  ; 绘制交叉相关图。
  res2                   = common_plot_settings()
  res2@gsnDraw           = False
  res2@gsnFrame          = False
  res2@gsnScale          = True
  res2@vpHeightF         = 0.40
  res2@vpWidthF          = 0.85
  res2@vpXF              = 0.10
  res2@vpYF              = 0.75

  lag = ispan(-mxlag, mxlag, 1)
  lag@long_name = "Lag (days)"

  plot(0) = gsn_csm_xy(wks, lag, ccr_12, res2)
  draw(plot(0))
  frame(wks)

  ; 绘制MJO指数图。
  res3                        = common_plot_settings()
  res3@gsnDraw                = False
  res3@gsnFrame               = False
  res3@gsnScale               = True
  res3@vpHeightF              = 0.40
  res3@vpWidthF               = 0.85
  res3@vpXF                   = 0.10
  res3@vpYF                   = 0.75
  res3@gsnYRefLine            = 1.0
  res3@gsnYRefLineColor       = "black"
  res3@xyMonoDashPattern      = True
  res3@xyLineColors           = (/"black", "blue"/)
  res3@xyLineThicknesses      = (/1, 2/)
  res3@pmLegendWidthF         = 0.12
  res3@pmLegendHeightF        = 0.10
  res3@pmLegendParallelPosF   = 0.86
  res3@pmLegendOrthogonalPosF = -0.40
  res3@xyExplicitLegendLabels = (/"daily", "91-day runavg"/)

  mjo_ind_plt      = new ((/2,num_time/), typeof(mjo_ts_index))
  mjo_ind_plt(0,:) = mjo_ts_index
  mjo_ind_plt(1,:) = (/mjo_ts_index_smt/)

  yyyymmdd = cd_calendar(time, -2)
  yrfrac   = yyyymmdd_to_yyyyfrac(yyyymmdd, 0.0)

  plot(0) = gsn_csm_xy(wks, yrfrac, mjo_ind_plt, res3)
  draw(plot(0))
  frame(wks)

end
