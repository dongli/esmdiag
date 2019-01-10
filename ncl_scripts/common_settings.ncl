function common_plot_settings()
local res
begin

  res = True
  res@gsnDraw = False
  res@gsnFrame = False
  res@gsnSpreadColors = True

  ; 字体大小
  res@txFontHeightF = 0.02
  res@gsnPanelMainStringFontHeightF = 0.02
  res@tiMainFontHeightF = 0.01
  res@gsnStringFontHeightF = 0.01
  res@tmXTLabelFontHeightF = 0.01
  res@tmXBLabelFontHeightF = 0.01
  res@tmYLLabelFontHeightF = 0.01
  res@tmYRLabelFontHeightF = 0.01
  res@lbLabelFontHeightF = 0.01
  res@lbTitleFontHeightF = 0.01
  res@cnLineLabelFontHeightF = 0.018

  ; 坐标刻度
  res@pmTickMarkDisplayMode = "Always"

  err = NhlGetErrorObjectId()
  setvalues err
    "errLevel" : "Fatal"
  end setvalues
  return res

end

function common_panel_settings()
local res
begin

  res = True
  res@gsnPanelYWhiteSpacePercent = 5

  return res

end

