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

  def version
    puts Shebang::Version
    exit
  end

  def index
    puts "Your name is #{@options[:n]}"
  end

  def test
    puts 'This is a test method'
  end
end

Shebang.run
