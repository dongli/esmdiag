module ScriniumEsmDiag
  class Dataset
    Actions = {
      :has_options => [
        :vinterp, :filter
      ].freeze,
      :has_no_option => [
        :anomaly
      ].freeze
    }.freeze

    attr_reader :variables

    def initialize
      @root = nil
      @variables = {}
    end

    def root arg = nil
      raise 'root should only be set once!' if @root and arg
      @root = arg if arg
      @root
    end

    def requires *args
      for i in 0..args.size-1
        case args[i]
        when Symbol
          @variables[args[i]] ||= {}
        when Array
          requires *args[i]
        when Hash
          raise 'requires syntax error!' if i != 1 or args[0].class != Array
          args[0].each { |var| @variables[var].merge! args[i] }
        end
      end
    end

    Actions[:has_options].each do |action|
      self.class_eval <<-EOT
        def #{action} vars, options
          if vars == :all
            raise 'no variable is required yet!' if @variables.empty?
            #{action} @variables.keys, options
          elsif vars.class == Symbol
            #{action} [ vars ], options
          elsif vars.class == Array
            vars.each do |var|
              @variables[var] ||= {}
              @variables[var][:#{action}] = options
            end
          end
        end
      EOT
    end

    Actions[:has_no_option].each do |action|
      self.class_eval <<-EOT
        def #{action} *vars
          vars.each do |var|
            if var == :all
              raise 'no variable is required yet!' if @variables.empty?
              #{action} *@variables.keys
            else
              @variables[var] ||= {}
              @variables[var][:#{action}] = nil
            end
          end
        end
      EOT
    end
  end
end
