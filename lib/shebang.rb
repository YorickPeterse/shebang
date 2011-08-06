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

    # The amount of spaces to insert before each option.
    :indent => '  ',

    # The format for each header for help topics, options, etc.
    :heading => "\n%s:\n"
  }

  # Hash containing the names of all commands and their classes.
  Commands = {}

  ##
  # Runs a command based on the command line arguments. If no command is given
  # this method will try to invoke the default command.
  #
  # @author Yorick Peterse
  # @since  0.1
  # @param  [Array] argv Array containing the command line arguments to parse.
  #
  def self.run(argv=ARGV)
    if Commands.empty?
      raise(Error, "No commands have been registered")
    end

    command = Config[:default_command]

    # Try to find the command from the command line.
    if !argv.empty?
      argv.each do |arg|
        if arg[0] != '-' and Commands.key?(arg.to_sym)
          command = arg
          break
        end
      end
    end

    command = command.to_sym

    if Commands.key?(command)
      command = Commands[command].new
      command.parse(argv)
      command.run
    else
      raise(Error, "The command #{command} does not exist")
    end
  end
end # Shebang
