module Tor
  module Probability
    # A container module for help considerations.
    module HelperPool
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
          @number = number
          @universe = universe
        end
        attr_reader :number

        # @param modified_difficulty [Integer] the modified dice roll
        # that the helpers are trying to achieve.
        #
        # @return [Float] the probability that at least one of the
        # helpers succeeds.
        def chance_someone_succeeds_at(modified_difficulty)
          chance_of_success =
            @universe.chance_of_gt_or_eq_to(modified_difficulty)
          accumulate(
            chance_of_success: chance_of_success,
            count: @number
          )
        end

        private

        # A recursive function that performs the following:
        #
        # Probability of success by the first helper +
        # ( Prob of failure of first helper *
        #   Probability of sucess of remaining helpers )
        #
        # @param chance_of_success [Float] the chance of success;
        # Assumed to be uniform across all helpers
        #
        # @param accumulator [Float] the accumulated chance of
        # success.
        #
        # @param count [Integer] the number of helpers left in the
        # calculation
        def accumulate(chance_of_success:, accumulator: 0.0, count:)
          return accumulator if count <= 0

          chance_current_helper_matters = 1 - accumulator
          accumulator += chance_current_helper_matters *
                         chance_of_success
          accumulate(
            chance_of_success: chance_of_success,
            count: count - 1,
            accumulator: accumulator)
        end
      end
    end
  end
end