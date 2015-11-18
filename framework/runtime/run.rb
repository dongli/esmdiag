module ScriniumEsmDiag
  def self.run command
    CLI.blue_arrow command
    system command
    CLI.report_error "Failed to run command!" if not $?.success?
  end
end

def cdo *args
  ScriniumEsmDiag.run "cdo --history #{args.join}"
end

def ncl *args
  ScriniumEsmDiag.run "ncl -Q #{args.join.gsub('=true', '=True').gsub('=false', '=False')}"
end
