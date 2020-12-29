module Tor
  module Probability
    # A container for the different kinds of checks
    module Check
      # Originally extracted as a parameter object (because the
      # `success_probability_for_given_check_or_later` method had too
      # many parameters), this object helps encapsulate the data used
      # to calculate each round's probability of success.
      class Swn
        PARAMETERS = [
          :universe,
          :modified_difficulty,
          :reroll,
          :chance_we_need_this_round,
          :round,
          :helpers
        ]

        def initialize(**kwargs)
          PARAMETERS.each do |param|
            instance_variable_set("@#{param}", kwargs.fetch(param))
          end
        end

        # @return [Universe] The universe of possible modified dice
        # rolls.
        attr_reader :universe

        # @return [Integer] The check's Difficulty Class (DC) plus all
        # of the modifiers (excluding those for rounds since dropping
        # to 0 HP) affecting the 2d6 roll.
        #
        # @note for a Heal-2 medic with a Dex of +1 using a Lazurus
        # Patch (DC 6) would have a modified_difficulty of
        # 3. (e.g. 6 - 2 - 1 = 3)
        #
        # @note for an untrained medic with a Dex of -1 using a
        # Lazurus Patch (DC 6) would have a modified_difficulty of
        # 3. (e.g. 6 - (-1) - (-1) = 9)
        attr_reader :modified_difficulty

        # @return [Boolean] True if we allow a reroll.
        attr_reader :reroll

        # @return [Float] The probability that we need this round,
        # range between 0.0 and 1.0.
        attr_reader :chance_we_need_this_round

        # @return [Integer] The round in which we start making checks;
        # How many rounds prior did the victim drop to 0 HP/
        attr_reader :round

        # @return [HelperPool] Who are the helpers for this task
        attr_reader :helpers

        def next(**kwargs)
          new_kwargs = {}
          PARAMETERS.each do |param|
            new_kwargs[param] = kwargs.fetch(param) do
              instance_variable_get("@#{param}")
            end
          end
          self.class.new(**new_kwargs)
        end

        # @return [Float]
        def probability_of_success_this_round
          dc = modified_difficulty + round
          universe.chance_of_gt_or_eq_to(dc)
        end

        # @return [Float]
        def chance_of_help_making_the_difference
          dc = modified_difficulty + round
          universe.chance_of_exactly(dc - 1) *
            helpers.chance_someone_succeeds_at(dc)
        end

        # @param prob [Float] The probability of succeeding
        #
        # @return [Float]
        def probability_of_reroll_makes_difference(prob:)
          # If you don't get a re-roll, there's no chance of a reroll
          # making the difference.
          return 0.0 unless reroll

          (1 - prob) * prob
        end
      end
    end
  end
end
