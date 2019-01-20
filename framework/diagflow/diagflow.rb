module EsmDiag
  class Diagflow
    include DiagflowDSL

    attr_reader :figures

    def initialize
      metric = self.class.to_s.gsub(/EsmDiag::Diagflow_/, '')
      eval "@figures = @@figures_#{metric}"
    end

    def run metric
      @figures.each do |tag, figure|
        ncl "#{ENV['ESMDIAG_ROOT']}/metrics/#{metric}/plot_#{tag}.ncl ", {
          model_id: ConfigManager.model_info.id,
          model_atm_id: ConfigManager.model_info.atm && ConfigManager.model_info.atm.id,
          model_lnd_id: ConfigManager.model_info.lnd && ConfigManager.model_info.lnd.id,
          model_ocn_id: ConfigManager.model_info.ocn && ConfigManager.model_info.ocn.id,
          model_ice_id: ConfigManager.model_info.ice && ConfigManager.model_info.ice.id,
          case_id: ConfigManager.case_info.id,
          start_date: ConfigManager.date.start,
          end_date: ConfigManager.date.end
        }
      end
    end
  end
end
