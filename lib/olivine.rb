# frozen_string_literal: true

require_relative "olivine/version"
require 'victor'
require 'matrix'
require 'pathname'
require 'prime'
require 'active_support'
require 'active_support/core_ext/class/subclasses'
require 'bigdecimal/util'

module Olivine
  class Error < StandardError; end
  # Your code goes here...
  module Generator
    # Generator module
  end
end

unless defined?(require_dir)
  def require_dir(dirname, target: /\.rb$/)
    dir = Pathname.new(caller.first[/^(.+?):(\d+)(?::in `(.*)')?/, 1]).dirname + dirname

    dir.children.each do |f|
      basename = f.basename.to_s
      require f if basename.match?(target)
    end
  end
end

require_dir 'olivine/exts'
require_relative 'olivine/path_finder.rb'
require_relative 'olivine/generator.rb'
