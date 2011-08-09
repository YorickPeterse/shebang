class SpecCommand < Shebang::Command
  command :default
  banner  'The default command.'
  usage   'shebang.rb [COMMAND] [OPTIONS]'

  o :v, :version, 'Shows the current version', :method => :version

  def index
    puts 'index method'
  end

  def test
    puts 'test method'
  end

  protected

  def version
    puts '0.1'
  end
end # SpecCommand
