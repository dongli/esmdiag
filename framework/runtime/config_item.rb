module EsmDiag
  class ConfigItem < Hash
    def initialize permitted_keys, item
      @item = {}
      item.each do |key, value|
        key = key.to_sym
        raise "#{key} is not permitted!" if not permitted_keys.has_key? key
        case value
        when Hash
          begin
            @item[key] = ConfigItem.new permitted_keys[key], value
          rescue
            @item[key] = value
          end
        else
          @item[key] = value
        end
        self.class.send(:define_method, key) do
          @item[key]
        end
        self.class.send(:define_method, :"#{key}=") do |value|
          @item[key] = value
        end
      end
      permitted_keys.each_key do |key|
        if not self.respond_to? key
          self.class.send(:define_method, key) do
            nil
          end
          self.class.send(:define_method, :"#{key}=") do |value|
            @item[key] = value rescue nil
          end
        end
      end
    end

    def each &block
      @item.select{ |k, v| k != :id }.each &block
    end

    def inspect
      @item.inspect
    end

    def [] key
      @item[key]
    end

    def has_key? key
      @item.has_key? key
    end

    def keys
      @item.keys
    end
  end
end
