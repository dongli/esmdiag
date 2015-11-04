$LOAD_PATH << "#{ENV['SCRINIUM_ESM_DIAG_ROOT']}/framework"

require 'runtime/config_manager'
require 'dataflow/dataset'
require 'dataflow/dataflow_dsl'
require 'dataflow/dataflow'
require 'dataflow/dataflow_manager'

ScriniumEsmDiag::ConfigManager.init
