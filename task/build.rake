# Task group used for building various elements such as the Gem and the
# documentation.
namespace :build do
  desc 'Builds the documentation using YARD'
  task :doc do
    gem_path = File.expand_path('../../', __FILE__)
    command  = "yard doc #{gem_path}/lib -m markdown -M rdiscount -o #{gem_path}/doc "
    command += "-r #{gem_path}/README.md --private --protected"

    sh(command)
  end

  desc 'Builds a new Gem'
  task :gem do
    gem_path     = File.expand_path('../../', __FILE__)
    gemspec_path = File.join(
      gem_path,
      "#{Shebang::Gemspec.name}-#{Shebang::Gemspec.version.version}.gem"
    )

    pkg_path = File.join(
      gem_path,
      'pkg',
      "#{Shebang::Gemspec.name}-#{Shebang::Gemspec.version.version}.gem"
    )

    # Build and install the gem
    sh('gem', 'build'     , File.join(gem_path, 'shebang.gemspec'))
    sh('mv' , gemspec_path, pkg_path)
    sh('gem', 'install'   , pkg_path)
  end
end # namespace :build

