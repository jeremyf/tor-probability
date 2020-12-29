module Tor
  module Probability
    module Scenario
      # A container module
      module SwnStabilization
        # The probability of success for the given check.
        #
        # @param check [Check] The current round's Check context.
        #
        # @param ttl [Integer] "Time to Live" - After this many rounds
        # without treatment, a character dies.
        #
        # @return [Float] The probability of success in this round or
        # all future rounds. Range between 0.0 and 1.0
        #
        # @note This is a recursive function.
        #
        # @note Per SWN rules, characters die after 6 rounds without
        # treatment.
        def self.success_chance_on_given_check_or_later(check:, ttl: 6)
          return 0 if check.round >= ttl

          prob = check.probability_of_success_this_round

          # Using the assumption that the best character is making the
          # check, and everyone that could be helping is using their
          # best check to help.  With the assumption that everyone has
          # the same modifier as the base check.
          prob += check.chance_of_help_making_the_difference

          # I believe the interaction of helpers and reroll is
          # correct.  We only attempt a re-roll if the helpers didn't
          # succeed.  And the re-roll has the same probability of
          # success
          prob += check.probability_of_reroll_makes_difference(
            prob: prob)

          # Assume that people will use their re-roll when the odds
          # are most in their favor (e.g. the first roll)
          next_check = check.next(
            round: check.round + 1,
            reroll: false,
            chance_we_need_this_round: (1 - prob)
          )

          check.chance_we_need_this_round * (
            prob + success_chance_on_given_check_or_later(
              check: next_check)
          )
        end
      end
    end
  end
end
