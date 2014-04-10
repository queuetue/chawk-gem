require 'active_record'
module Chawk
  module Models
    # TODO: Most expensive version imaginable.  To be replaced.
    class Aggregator
    # Aggregator provides statistical and aggregate operations on ranges.

      attr_reader :dataset

      def initialize(node)
        node.check_read_access
        if node.points.length > 0
          @dataset = node.points.to_a.reduce([]) { |a, e| a << e.value }
        end
      end

      def max
        @dataset.max
      end

      def min
        @dataset.min
      end

      def mean
        sum.to_f / @dataset.length
      end

      def sum
        @dataset.reduce(0) { |a , e| a += e }
      end

      def count
        @dataset.length
      end

      def sumsqr
        @dataset.map { |x| x * x }.reduce(&:+)
      end

      def stdev
        m = mean
        Math.sqrt((sumsqr - count * m * m) / (count - 1))
      end
    end
  end
end
