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

def ncl *args
  EsmDiag.run "ncl -Q #{args.join.gsub('=true', '=True').gsub('=false', '=False')}"
end
