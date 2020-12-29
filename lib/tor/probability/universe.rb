module Tor
  module Probability
    # This class encapsulates the probability calculations based on
    # the given :distribution.
    class Universe
      # Return a Universe object with a dice result distribution
      # of the sum of two six-sided dice.
      #
      # @note Think to your Settlers of Catan board game.  The "dot"
      # on each of the number chits is the chance in 36 of rolling
      # that number on 2d6.
      def self.two_six_sided_dice
        new(
          label: '2d6',
          distribution: {
            2 => 1, 3 => 2, 4 => 3,
            5 => 4, 6 => 5, 7 => 6,
            8 => 5, 9 => 4, 10 => 3,
            11 => 2, 12 => 1
          }
        )
      end

      # Return a Universe object with a dice result distribution
      # of the sum of the highest two results of three six-sided dice.
      def self.three_six_sided_dice_keep_best_two
        new(
          label: "3d6",
          distribution: {
            2  => 1, 3  => 3, 4  => 7,
            5  => 12, 6  => 19, 7  => 27,
            8  => 34, 9  => 36, 10 => 34,
            11 => 27, 12 => 16
          })
      end

      # Return a Universe object with a dice result distribution
      # of the sum of the highest two results of four six-sided dice.
      def self.four_six_sided_dice_keep_best_two
        new(
          label: "4d6",
          distribution: {
            2 => 1, 3 => 4, 4 => 15, 5 => 32,
            6 => 65, 7 => 108, 8 => 171, 9 => 224,
            10 => 261, 11 => 244, 12 => 171
          }
        )
      end

      def initialize(label:, distribution:)
        @label = label
        @distribution = distribution.freeze
        @max = distribution.keys.max
        @size = distribution.values.sum.to_f
      end
      attr_reader :label

      # Given the :modified_target, what is the chance of a result
      # equal to or greater than that target?
      #
      # @param modified_target [Integer] What is the roll we're looking
      # for?
      #
      # @return [Float] the chance, with a range between 0 and 1.
      def chance_of_gt_or_eq_to(modified_target)
        @distribution.slice(*(modified_target..@max)).values.sum /
          @size
      end

      # Given the :modified_target, what is the chance of a result
      # equal to exactly the modified target?
      #
      # @param modified_target [Integer] What is the roll we're looking
      # for?
      #
      # @return [Float] the chance, with a range between 0 and 1.
      def chance_of_exactly(modified_target)
        @distribution.fetch(modified_target, 0) / @size
      end
    end
  end
end
