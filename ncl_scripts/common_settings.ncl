function common_plot_settings()
local res
begin

  res = True
  res@gsnDraw = False
  res@gsnFrame = False
  res@gsnSpreadColors = True

  ; 字体大小
  res@gsnStringFontHeightF = 0.025
  res@tmXTLabelFontHeightF = 0.02
  res@tmXBLabelFontHeightF = 0.02
  res@tmYLLabelFontHeightF = 0.02
  res@tmYRLabelFontHeightF = 0.02
  res@lbLabelFontHeightF = 0.02
  res@lbTitleFontHeightF = 0.02
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

