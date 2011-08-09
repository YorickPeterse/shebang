require File.expand_path('../lib/shebang', __FILE__)

module Shebang
  Gemspec = Gem::Specification::load(File.expand_path('../shebang.gemspec', __FILE__))
end

task_dir = File.expand_path('../task', __FILE__)

Dir.glob("#{task_dir}/*.rake").each do |f|
  import(f)
end
