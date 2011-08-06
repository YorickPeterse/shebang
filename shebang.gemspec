require File.expand_path('../lib/shebang/version', __FILE__)

path = File.expand_path('../', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'shebang'
  s.version     = Shebang::Version
  s.date        = '06-08-2011'
  s.authors     = ['Yorick Peterse']
  s.email       = 'yorickpeterse@gmail.com'
  s.summary     = ''
  s.homepage    = 'https://github.com/yorickpeterse/shebang'
  s.description = ''
  s.files       = `cd #{path}; git ls-files`.split("\n").sort
  s.has_rdoc    = 'yard'

  s.add_development_dependency('rake' , ['~> 0.9.2'])
  s.add_development_dependency('yard' , ['~> 0.7.2'])
  s.add_development_dependency('bacon', ['~> 1.1.0'])
end
