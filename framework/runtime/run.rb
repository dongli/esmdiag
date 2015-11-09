module ScriniumEsmDiag
  def self.run command
    CLI.blue_arrow command
    #res = `#{command} 2>&1`
    #if not $?.success?
    #  CLI.report_error "Failed to run command!\n#{res.split("\n").map { |x| "## #{x}" }.join}"
    #end
    system command
  end
end
