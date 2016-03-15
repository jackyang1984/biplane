require "./printer/*"

module Biplane
  module Printer
    class EmptyDiff
      def initialize(@diff)
      end

      def print
        puts "No differences found!".colorize(:green)
      end
    end

    FORMATS = {
      "nested": NestedDiff,
      "flat":   FlatDiff,
      "empty":  EmptyDiff,
    }

    def self.new(diff, format = "nested")
      format = "empty" if diff.empty?

      begin
        FORMATS[format].new(diff)
      rescue KeyError
        puts "Could not find formatter for '#{format}' (allowed: nested, flat).".colorize(:red)
        exit(1)
      end
    end
  end
end