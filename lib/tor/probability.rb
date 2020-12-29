require "tor/probability/version"
require "tor/probability/universe"
require "tor/probability/helper_pool"
require "tor/probability/scenario"
require "tor/probability/check"

module Tor
  module Probability
    class Error < StandardError; end

    # @param output_filename [String] The filename in which this
    # script will dump the YAML file.
    #
    # @see https://takeonrules.com/2020/12/28/probability-of-stabilizing-the-dying-in-stars-without-number/
    def self.swn_stabilization_scenarios(output_filename:)
      universe_2d6 = Universe.two_six_sided_dice
      universe_3d6 = Universe.three_six_sided_dice_keep_best_two

      all_helpers = [
        HelperPool::SwnAidAnother.new,
        HelperPool::SwnAidAnother.new do
          add_helper(universe: universe_2d6)
        end,
        HelperPool::SwnAidAnother.new do
          add_helper(universe: universe_2d6)
          add_helper(universe: universe_2d6)
        end
      ]

      number_of_rounds = (0..5)
      header_template = "| %-10s | %-4s | %7s | %6s" +
                        " | %5s" * number_of_rounds.size + " |"
      divider_template = "|------------+------+---------+--------" +
                         ("+-------" * number_of_rounds.size) + "|"
      line_template = "| %-10s | %-4s | %-7d | %6s" +
                      " | %.3f" * number_of_rounds.size + " |"
      header = sprintf(header_template, "Mod Diff", "Dice", "Helpers",
                       "Reroll",
                       *number_of_rounds.to_a.map {|i| "Rnd #{i}"})
      puts header
      puts divider_template

      rows = []
      (0..12).each do |modified_difficulty|
        [universe_2d6, universe_3d6].each do |universe|
          all_helpers.each do |helpers|
            [false, true].each do |reroll|
              report_rounds = number_of_rounds.map do |round|
                check = Check::Swn.new(
                  reroll: reroll,
                  universe: universe,
                  modified_difficulty: modified_difficulty,
                  chance_we_need_this_round: 1.0,
                  helpers: helpers,
                  round: round
                )
                Scenario::SwnStabilization.success_chance_on_given_check_or_later(
                  check: check)
              end
              rows << {
                "Modified Difficulty" => modified_difficulty,
                "Dice Rolled" => universe.label,
                "Helpers" => helpers.number,
                "Reroll" => reroll,
                "Round 0" => sprintf("%.3f", report_rounds[0]),
                "Round 1" => sprintf("%.3f", report_rounds[1]),
                "Round 2" => sprintf("%.3f", report_rounds[2]),
                "Round 3" => sprintf("%.3f", report_rounds[3]),
                "Round 4" => sprintf("%.3f", report_rounds[4]),
                "Round 5" => sprintf("%.3f", report_rounds[5])
              }
              puts sprintf(line_template,
                           modified_difficulty,
                           universe.label,
                           helpers.number,
                           reroll,
                           *report_rounds)
            end
          end
        end
      end

      # Below is used for writing a YAML file that I use to auto-generate
      # the table for a blog post.

      column_names = [
        "Modified Difficulty",
        "Dice Rolled",
        "Helpers",
        "Reroll",
        "Round 0",
        "Round 1",
        "Round 2",
        "Round 3",
        "Round 4",
        "Round 5"
      ]

      columns = []
      column_names.each do |name|
        columns << { "label" => name, "key" => name }
      end

      require 'psych'
      File.open(output_filename, "w+") do |file|
        file.puts(
          Psych.dump(
            "name" => 'Probability of Stabilization in SWN',
            "columns" => columns,
            "rows" => rows
          )
        )
      end
    end

  end
end
