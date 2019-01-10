module EsmDiag
  class Cache
    def self.path
      '.cache'
    end

    def self.read
      @@cache_hash = eval File.open(path, 'r').read if File.exist? path
      @@cache_hash ||= {}
    end

    def self.write
      File.open(path, 'w') do |file|
        PP.pp @@cache_hash, file
      end
    end

    def self.save_pipeline output_file_name
      @@cache_hash[output_file_name] ||= {}
      @@cache_hash[output_file_name][:timestamp] = File.ctime(output_file_name).to_s if File.exist? output_file_name
      write
    end

    def self.already_generated? output_file_name
      return false if not @@cache_hash[output_file_name] 
      @@cache_hash[output_file_name][:timestamp] == File.ctime(output_file_name).to_s if File.exist? output_file_name
    end
  end
end
