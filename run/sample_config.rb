model_id = 'GAMIL'
case_id = 'piControl-bugfix-licom-80368d'
date = {
  start: '0020-01-01',
  end: '0030-12-31'
}
model_data = {
  atm: {
    root: '~/CMIP6/run/piControl-bugfix-licom-80368d/run',
    mesh: 'lat_lon',
    fixed: {
      wgt_lat: 'gw'
    },
    monthly: {
      pattern: "#{case_id}.gamil.h0.*.nc"
    },
    daily: {
      pattern: "#{case_id}.gamil.h1.*.nc"
    }
  }
}
use_metrics = { climo: {} }
