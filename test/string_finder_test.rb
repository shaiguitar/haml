require 'test_helper'

module Haml
  class StringFinderTest < MiniTest::Unit::TestCase

    test "ignores silent scripts" do
      begin
        result = find_text "- if true\n  - case @foo\n  - when 1\n    bar\n- else\n  bar"
        assert_equal result, true
      rescue SyntaxError
        flunk 'else clause after if containing case should be accepted'
      end
    end

    test "else after if containing unless is accepted" do
      begin
        result = find_text "- if true\n  - unless @foo\n  bar\n- else\n  bar"
        assert_equal result, true
      rescue SyntaxError
        flunk 'else clause after if containing unless should be accepted'
      end
    end
    
    test "loud script with else is accepted" do
      begin
        result = find_text "= if true\n  - 'A'\n-else\n  - 'B'"
        assert_equal result, true
      rescue SyntaxError
        flunk 'loud script (=) should allow else'
      end
    end

    test "else after nested loud script is accepted" do
      begin
        result = find_text "-if true\n  =if true\n    - 'A'\n-else\n  B"
        assert_equal result, true
      rescue SyntaxError
        flunk 'else after nested loud script should be accepted'
      end
    end

    test "case with indented whens should allow else" do
      begin
        result = find_text "- foo = 1\n-case foo\n  -when 1\n    A\n  -else\n    B"
        assert_equal result, true
      rescue SyntaxError
        flunk 'case with indented whens should allow else'
      end
    end

    private

    def find_text(haml)
      find_text = FindText.new(haml)
      find_text.run
    end
  end
end