require File.expand_path('../../helper', __FILE__)
require File.expand_path('../../fixtures/command', __FILE__)

module Kernel
  def abort(*args)
    $stderr.puts(*args)
  end

  def exit(*args); end
end

describe('Shebang') do
  it('Raise an error message') do
    should.raise?(Shebang::Error) do
      Shebang.error('test')
    end
  end

  it('Display an error message') do
    Shebang::Config[:raise] = false

    output = catch_output do
      Shebang.error('test')
    end

    output[:stderr].include?('test').should === true
  end

  it('Invoke the default command') do
    [[], ['default'], ['default', 'index']].each do |argv|
      output = catch_output do
        Shebang.run(argv)
      end

      output[:stdout].strip.should === 'index method'
    end
  end

  it('Invoke the default command with an alternative method') do
    [['test'], ['default', 'test']].each do |argv|
      output = catch_output do
        Shebang.run(argv)
      end

      output[:stdout].strip.should === 'test method'
    end
  end

  it('Show a help message') do
    output = catch_output do
      Shebang.run(['--help'])
    end

    output[:stdout].include?('The default command').should            === true
    output[:stdout].include?('shebang.rb [COMMAND] [OPTIONS]').should === true
    output[:stdout].include?('Options').should                        === true
  end

  it('Shows the current version') do
    output = catch_output do
      Shebang.run(['--version'])
    end

    output[:stdout].include?('0.1').should === true
  end
end # describe
