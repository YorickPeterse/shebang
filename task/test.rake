desc 'Runs all the tests'
task :test do
  Dir.glob(File.expand_path('../../spec/shebang/*.rb', __FILE__)).each do |f|
    require(f)
  end
end
