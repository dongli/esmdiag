begin
  require 'minitest/reporters'
  reporter_options = { :color => true }
  Minitest::Reporters.use! [ Minitest::Reporters::SpecReporter.new(reporter_options) ]
rescue LoadError => e
end
