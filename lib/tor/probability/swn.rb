require "tor/probability/universe"

module Tor
  module Probability
    module Swn
      def calculate_skill_check(modified_difficulty: 8, re_roll: false, dice_pool: :2d6, helper_pool: [])
        skill_check = SkillCheck.new(modified_difficulty: modified_difficulty, re_roll: re_roll, dice_pool: dice_pool, helper_pool: helper_pool)
        skill_check.calculate
      end

      class SkillCheck
        def initialize(modified_difficulty: 8, re_roll: false, dice_pool: :2d6, helper_pool: [])
          @modified_difficulty = modified_difficulty
          @re_roll = re_roll
          self.dice_pool = dice_pool
          self.helper_pool = helper_pool
        end

        private

        def dice_pool=(value)
        end

        def helper_pool=(value)
          @helper_pool = HelperPool.new(pool: value)
        end
      end
    end
  end
end
