module ScriniumEsmDiag
  class Dataflow
    include DataflowDSL

    attr_reader :datasets

    def initialize
      metric = self.class.to_s.gsub(/ScriniumEsmDiag::Dataflow_/, '')
      eval "@datasets = @@datasets_#{metric}"
    end

    def run
      @datasets.each do |tag, dataset|
        dataset.variables.each do |var, actions|
          actions.each do |action, options|
            if options
              p "#{action} - #{options}"
            else
              p action
            end
          end
        end
      end
    end
  end
end
