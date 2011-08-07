require File.expand_path('../../lib/shebang', __FILE__)

class Greet < Shebang::Command
  command :default
  banner  'Runs an example command.'
  usage   '$ ruby example/basic.rb [OPTIONS]'

  o :h, :help   , 'Shows this help message'  , :method => :help
  o :v, :version, 'Shows the current version', :method => :version
  o :f, :force  , 'Forces the command to run'
  o :n, :name   , 'A person\'s name', :type => String,
    :required => true, :default => 'Shebang'

  # $ ruby example/basic.rb
  # $ ruby example/basic.rb default
  # $ ruby example/basic.rb default index
  def index
    puts "Your name is #{@options[:n]}"
  end

  # $ ruby example/basic.rb test
  # $ ruby example/basic.rb default test
  def test
    puts 'This is a test method'
  end

  protected

  def version
    puts Shebang::Version
    exit
  end
end

Shebang.run
