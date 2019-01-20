module EsmDiag
  def self.run command
    CLI.blue_arrow command
    system command
    CLI.report_error "Failed to run command!" if not $?.success?
  end
end

def cdo *args
  EsmDiag.run "cdo --history #{args.join}"
end

def ncl script, args = {}
  ncl_args = []
  args.delete_if { |k, v| v == nil }.each do |key, value|
    case value
    when String, Symbol, Date
      ncl_args << "#{key}=\\\"#{value}\\\""
    when Array
      ncl_args << "#{key}=\\\(/#{value.join(',')}/\\\)"
    when TrueClass, FalseClass
      ncl_args << "#{key}=#{value.to_s.capitalize}"
    else
      ncl_args << "#{key}=#{value}"
    end
  end
  EsmDiag.run "ncl -Q #{script} #{ncl_args.join(' ')}"
end
