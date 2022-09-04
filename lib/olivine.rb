# frozen_string_literal: true

require_relative "olivine/version"
require "victor"
require "matrix"
require "pathname"
require "prime"
require "active_support/all"
require "active_support/core_ext/class/subclasses"
require "bigdecimal/util"

module Olivine
  class Error < StandardError; end

  # Your code goes here...
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

require_dir "olivine/exts"
require_relative "olivine/path_finder"
require_relative "olivine/generator"

if __FILE__ == $PROGRAM_NAME
  require "optparse"
  require "erb"
  require "tempfile"
  require "kramdown"
  active_classes = Olivine::Generator::Base.descendants.select { |e| e.method_defined?(:expression) }.sort_by {|klass| klass.code }

  OptionParser.new do |opt|
    opt.on('-l', '--list') { active_classes.each_with_index { |klass, i| puts "%2i %s %s" % [i, klass.label, klass.name.match(/\w+::\w+$/)[0]] } }
    opt.on('-c', '--count') { active_classes.each { |klass| puts "%s %s : %d" % [klass.unit[0], klass.label, klass.new.generate.to_a.size] } }
    opt.on('-i INDEX') do |i|
      quizzes = []
      klass = active_classes[i.to_i]
      klass.new.generate { |*e| printf "count: %d\r" % quizzes.push(e).size }
      tmp = Tempfile.create(['', '.html'], '../tmp')
      puts "\n#{klass} done."
      tmp.write ERB.new(File.read('assets/template.erb'), trim_mode: '%-').result(binding)
      puts "written to #{tmp.path}"
      tmp.close
      `start #{tmp.path}`
    end

    opt.parse!
  end
end
