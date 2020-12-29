module Tor
  module Probability
    # A container module for help considerations.
    module HelperPool
      class Helper
        def initialize(universe:, relative_modifier: 0)
          @universe = universe
          @relative_modifier = relative_modifier
        end

        def chance_of_gt_or_eq_to(modified_difficulty)
          mdc = modified_difficulty - @relative_modifier
          @universe.chance_of_gt_or_eq_to(mdc)
        end
      end

      # This class encapsulates the probability of a helper
      #
      # A key assumption in helping is that all helpers are helping
      # with their preferred skill check, and thus the
      # modified_difficulty is the same as the person performing the
      # primary test.
      #
      # @note I tested this using a coin toss universe distribution
      # (e.g. heads or tails)
      class SwnAidAnother
        # @todo Provide ways for helers to vary in capability.
        #
        # @param number [Integer] the number of helpers
        #
        # @param universe [Universe] the universe of possible dice
        # results for each of the helpers
        def initialize(number:, universe:)
          @universe = universe
          @helpers = (0...number).map do
            Helper.new(universe: universe)
          end
        end
        attr_reader :helpers

        def count
          @helpers.count
        end
        alias number count

        # @param modified_difficulty [Integer] the modified dice roll
        # that the helpers are trying to achieve.
        #
        # @return [Float] the probability that at least one of the
        # helpers succeeds.
        def chance_someone_succeeds_at(modified_difficulty)
          accumulate(modified_difficulty: modified_difficulty)
        end

        private

        # A recursive function that performs the following:
        #
        # Probability of success by the first helper +
        # ( Prob of failure of first helper *
        #   Probability of sucess of remaining helpers )
        #
        # @param modified_difficulty [Integer] the modified dice roll
        # that the helpers are trying to achieve.
        #
        # @param accumulator [Float] the accumulated chance of
        # success.
        #
        # @param count [Integer] the number of helpers left in the
        # calculation
        def accumulate(modified_difficulty:, accumulator: 0.0, count: 0)
          return accumulator if count == @helpers.count

          helper = @helpers[count]
          chance_of_success = helper.chance_of_gt_or_eq_to(modified_difficulty)

          chance_current_helper_matters = 1 - accumulator

          accumulator += chance_current_helper_matters *
                         chance_of_success
          accumulate(
            modified_difficulty: modified_difficulty,
            count: count + 1,
            accumulator: accumulator)
        end
      end
    end
  end
end