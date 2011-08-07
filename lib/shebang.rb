require 'rubygems'
require 'optparse'
require File.expand_path('../shebang/version', __FILE__)
require File.expand_path('../shebang/command', __FILE__)
require File.expand_path('../shebang/option' , __FILE__)

##
# Shebang is a nice wrapper around OptionParser that makes it easier to write
# commandline executables.
#
# @author Yorick Peterse
# @since  0.1
#
module Shebang
  #:nodoc:
  class Error < StandardError; end

  # Hash containing various configuration options.
  Config = {
    # The name of the default command to invoke when no command is specified.
    :default_command => :default,

    # The name of the default method to invoke.
    :default_method => :index,

    # The amount of spaces to insert before each option.
    :indent => '  ',

    # The format for each header for help topics, options, etc.
    :heading => "\n%s:\n",

    # When set to true Shebang will raise an exception for errors instead of
    # just printing a message.
    :raise => true
  }

  # Hash containing the names of all commands and their classes.
  Commands = {}

  class << self
    ##
    # Runs a command based on the command line arguments. If no command is given
    # this method will try to invoke the default command.
    #
    # @author Yorick Peterse
    # @since  0.1
    # @param  [Array] argv Array containing the command line arguments to parse.
    #
    def run(argv = ARGV)
      self.error("No commands have been registered") if Commands.empty?

      command = Config[:default_command].to_sym
      method  = Config[:default_method].to_sym

      if !argv.empty?
        # Get the command name
        if argv[0][0] != '-' and Commands.key?(argv[0].to_sym)
          command = argv.delete_at(0).to_sym
        end
      end

      if Commands.key?(command)
        klass = Commands[command].new

        # Get the method to call.
        if argv[0] and argv[0][0] != '-' and klass.respond_to?(argv[0].to_sym)
          method = argv.delete_at(0).to_sym
        end

        # Parse the arguments and prepare all the options.
        argv = klass.parse(argv)

        # Call the method and pass the commandline arguments to it.
        if klass.respond_to?(method)
          if klass.class.instance_method(method).arity != 0
            klass.send(method, argv)
          else
            klass.send(method)
          end
        else
          error("The command #{command} does not have a #{method}() method")
        end
      else
        error("The command #{command} does not exist")
      end
    end

    ##
    # Raises an exception or prints a regular error message to STDERR based on
    # the :raise configuration option.
    #
    # @author Yorick Peterse
    # @since  0.1
    # @param  [String] message The message to display.
    #
    def error(message)
      if Config[:raise] === true
        raise(Error, message)
      else
        abort "\e[0;31mError:\e[0m #{message}"
      end
    end
  end # class << self
end # Shebang
