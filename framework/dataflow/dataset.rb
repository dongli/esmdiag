module EsmDiag
  class Dataset
    attr_accessor :root, :pattern, :data_list
    attr_reader :variables

    def initialize
      @variables = {}
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

    Dir.glob("#{ENV['ESMDIAG_ROOT']}/framework/actions/*.rb").map { |x| File.basename(x, File.extname(x)) }.each do |action|
      if Actions.respond_to? :"#{action}_accepted_options"
        options = Actions.send(:"#{action}_accepted_options")
      else
        options = nil
      end
      self.class_eval <<-EOT
        def #{action} *args
          accepted_options = #{options}
          if accepted_options
            input_options = {}
            vars = []
            args.each do |arg|
              if arg.class == Hash
                input_options = arg
              elsif accepted_options.keys.include? arg
                input_options[arg] = true
              elsif not input_options.empty?
                raise 'options should be put at last!'
              elsif arg.class == Symbol or arg.class == String
                vars << arg.to_sym
              end
            end
            vars.each do |var|
              var = var.to_sym
              if var == :all
                raise 'no variable is required yet!' if @variables.empty?
                #{action} *@variables.keys, input_options
              else
                @variables[var] ||= {}
                @variables[var][:#{action}] = input_options
              end
            end
          else
            args.each do |var|
              var = var.to_sym
              if var == :all
                raise 'no variable is required yet!' if @variables.empty?
                #{action} *@variables.keys
              elsif var.class == Symbol
                @variables[var] ||= {}
                @variables[var][:#{action}] = nil
              end
            end
          end
        end
      EOT
    end
  end
end
