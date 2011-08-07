# README

Shebang is a nice wrapper around OptionParser that makes it easier to write
commandline executables. I wrote it after getting fed up of having to re-invent
the same wheel every time I wanted to write a commandline executable. For
example, a relatively simple command using OptionParser directly may look like
the following:

    require 'optparse'

    @options = {:force => false, :f => false, :name => nil, :n => nil}
    parser   = OptionParser.new do |opt|
      opt.banner = <<-TXT.strip
    Runs an example command.

    Usage:
      $ foobar.rb [OPTIONS]
      TXT

      opt.summary_indent = '  '

      opt.separator "\nOptions:\n"

      opt.on('-h', '--help', 'Shows this help message') do
        puts parser
        exit
      end

      opt.on('-v', '--version', 'Shows the current version') do
        puts '0.1'
        exit
      end

      opt.on('-f', '--force', 'Forces the command to run') do
        @options[:force] = @options[:f] = true
      end

      opt.on('-n', '--name NAME', 'A person\'s name') do |name|
        @options[:name] = @options[:n] = name
      end
    end

    parser.parse!

    puts "Your name is #{@options[:name]}"

Using Shebang this can be done as following:

    require 'shebang'

    class Greet < Shebang::Command
      command :default
      banner  'Runs an example command.'
      usage   '$ foobar.rb [OPTIONS]'

      o :h, :help   , 'Shows this help message'  , :method => :help
      o :v, :version, 'Shows the current version', :method => :version
      o :f, :force  , 'Forces the command to run'
      o :n, :name   , 'A person\'s name', :type => String

      def version
        puts '0.1'
        exit
      end

      def index
        puts "Your name is #{@options[:n]}"
      end
    end

    Shebang.run

## Usage

As shown in the example above commands can be created by extending the class
``Shebang::Command`` and calling the class method ``command()``. Each command
required an instance method called ``index()`` to be defined, this method is
called once OptionParser has been set up and the commandline arguments have
been parsed:

    require 'shebang'

    class Greet < Shebang::Command
      command :default

      def index

      end
    end

The values of options and the commandline arguments (after they've been parsed)
can be accessed in a command using the instance variables ``@options`` and
``@argv``. The ``@options`` instance variable is a hash that contains the values
of all options of both the short and long option name. This means that if the
user specified the ``-n`` option you can still check it using
``@options[:help]``.

Options can be specified using the class method ``option()`` or it's alias
``o()``. Besides the features offered by OptionParser options can specify a
method to execute in case that particular option has been specified. This can be
done by passing the ``:method`` key to the option method:

    option :f, :foobar, 'Calls a method', :method => :foobar

Now whenever the ``-f`` of ``--foobar`` option is set the method ``foobar()``
will be executed **without** stopping the rest of the command. This means that
you'll have to manually call ``Kernel.exit()`` if you want to stop the execution
process if a certain option is specified.

Shebang comes with support for defining sub commands. Sub commands are nothing
more than different methods than the default one. Say you have a class
``Git::Submodule``, to run the command itself you'd invoke the default method on
this class (index by default):

    cmd = Git::Submodule.new

    cmd.parse([...])
    cmd.index

To show the status of a submodule you'd invoke ``git submodule status``, this
translates to the following code:

    cmd = Git::Submodule.new

    cmd.parse([...])
    cmd.status

Shebang takes care of this using ``Shebang.run()``. The first commandline
argument that does not start with ``-`` (and this isn't an option) is considered
the command name. If there's another argument that's not a switch following that
one will be used as the method name. This means that in order to invoke
``Git::Submodule#index`` you'd type the following into your terminal:

    git.rb submodule

If you want to invoke a method other than the default one you'd do the
following:

    git.rb submodule status

In other words, the syntax of a Shebang command is the following:

    script [COMMAND] [METHOD] [ARGS] [OPTIONS]

## Configuration

Various options of Shebang can be configured by modifying the hash
``Shebang::Config``. For example, if you want to change the format of all the
headers in the help message you can do so as following:

    Shebang::Config[:heading] = "\n== %s:\n"

You can also change the name of the default command:

    Shebang::Config[:default_command] = :my_default_command

## Parsing Customization

By default Shebang uses OptionParser#parse! to parse a set of commandline
arguments. If you want to change this behavior you can do so by defining a
method called ``parse()`` in your classes:

    def parse(argv=[])
      # Do something here...
    end

Say you want to use sub commands, in that case you'll have to use
``OptionParser#order!``, this can be done as following:

    def parse(argv=[])
      @argv = argv
      @option_parser.order!(@argv)
    end
