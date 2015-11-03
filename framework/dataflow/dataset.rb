module ScriniumEsmDiag
  class Dataset
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

    def raw *args
      args.each do |name|
        @variables[name] = {}
      end
    end

    def rename args
      args.each do |old_name, new_name|
        @variables[old_name] ||= {}
        @variables[old_name][:rename] = new_name
      end
    end

    def vinterp args
      args.each do |names, levels|
        names = [ names ] if names.class != Array
        names.each do |name|
          @variables[name] ||= {}
          @variables[name][:vinterp] ||= []
          @variables[name][:vinterp] << levels
          @variables[name][:vinterp].flatten! if levels.class == Array
          @variables[name][:vinterp].uniq!
        end
      end
    end
  end
end
