$LOAD_PATH << "#{ENV['SCRINIUM_ESM_DIAG_ROOT']}/framework"

require 'pp'
require 'digest'
require 'fileutils'

require 'runtime/cli'
require 'runtime/run'
require 'runtime/config_manager'
require 'runtime/cache'
require 'actions/anomaly'
require 'actions/extract'
require 'actions/filter'
require 'actions/vinterp'
require 'dataflow/dataset'
require 'dataflow/dataflow_dsl'
require 'dataflow/dataflow'
require 'dataflow/dataflow_manager'
require 'diagflow/figure.rb'
require 'diagflow/diagflow_dsl'
require 'diagflow/diagflow'
require 'diagflow/diagflow_manager'

ScriniumEsmDiag::ConfigManager.init
