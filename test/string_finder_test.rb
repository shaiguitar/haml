require 'test_helper'

module Haml
  class StringFinderTest < MiniTest::Unit::TestCase

    # random tests from before used, just leaving them for now, cleanup later
    # test "finds all the text in a statement" do
    #   result = find_text "- if true\n  - case @foo\n  - when 1\n    cheese\n- else\n  rice"
    #   assert_equal result, ["cheese", "rice"]
    # end
    # 
    # test "finds all the text in a statement" do
    #   result = find_text "- if true\n  - unless @foo\n  blue\n- else\n  green"
    #   assert_equal result, ["blue", "green"]
    # end
    # 
    # test "finds silent script with strings" do
    #   result = find_text "= if true\n  - 'hank'\n-else\n  - 'bob'"
    #   assert_equal result, ["hank", "bob"]
    # end
    # 
    # test "also this" do
    #   result = find_text "- foo = 1\n-case foo\n  -when 1\n    crown\n  -else\n    brown"
    #   assert_equal result, ["crown", "brown"]
    # end

    # regular text mode
    test "silent scripts with strings and regular text" do
      assert_equal find_text("iphone"), ["iphone"]
      assert_equal find_text("  iphone4"), ["iphone4"]
    end


    # silent script mode
    test "silent scripts with strings and regular text" do
      assert_equal find_text("-if true\n  =if true\n    - 'jessica'\n-else\n  sheen"), ["jessica", "sheen"]
    end
    
    # html element mode
    test "%tag Text" do
      assert_equal find_text("%span Text to find"), ["Text to find"]
    end

    test "%tag Text with class" do
      assert_equal find_text("%span.whatever-with-thing Text to find"), ["Text to find"]
    end

    test "%tag Text with ruby eval code" do
      assert_equal find_text("%span= ruby_eval_code"), []
    end

    test "%tag Text with ruby eval code and class" do
      assert_equal find_text( "%span#whatever-with-thing= ruby_eval_code"), []
    end
    
    test "Ruby style tags %a{'href' => 'http://whatever'} whatever" do
      assert_equal find_text("%a{'href' => 'http://whatever'} whatever"), ["whatever"]
    end
    
    # loud scripts / ruby eval mode
    test "loud scripts with strings" do
      assert_equal find_text('= "bob"'), ["bob"]
      assert_equal find_text("= 'bob'"), ["bob"]
    end

    test "loud scripts does not interpolate ruby vars in strings" do
      assert_equal find_text('= "ruby can #{var}"'), ["ruby can \#{var}"]
    end
    
    # special loud scripts exceptions
    test "it finds link_to texts as an exception to the rule" do
      assert_equal find_text('= link_to "This should be found", "/"'), ["This should be found"]
    end
    
    test "it finds link_to texts as an exception to the rule and does not interpolate" do
      assert_equal find_text('= "Statistics for #{@name}"'), ["Statistics for \#{@name}"]
    end

    # html element mode with ruby evaling
    test "html element with ruby eval with strings" do
      assert_equal find_text('%p= "bob"'), ["bob"]
      assert_equal find_text("%p.what= 'bob'"), ["bob"]
      assert_equal find_text("%p.what{:attr => :val}= 'bob'"), ["bob"]
    end
    
    test "html element loud scripts does not interpolate ruby vars in strings" do
      assert_equal find_text('%p= "ruby can #{var}"'), ["ruby can \#{var}"]
      assert_equal find_text('%p.what= "ruby can #{var}"'), ["ruby can \#{var}"]
      assert_equal find_text('%p.what{:attr => :val}= "ruby can #{var}"'), ["ruby can \#{var}"]
    end
    
    test "html element it finds link_to texts as an exception to the rule" do
      assert_equal find_text('%p= link_to "This should be found", "/"'), ["This should be found"]
      assert_equal find_text('%p.what= link_to "This should be found", "/"'), ["This should be found"]
      assert_equal find_text('%p.what{:attr => :val}= link_to "This should be found", "/"'), ["This should be found"]
    end
    
    test "html element it finds link_to texts as an exception to the rule and does not interpolate" do
      assert_equal find_text('%p= "Statistics for #{@name}"'), ["Statistics for \#{@name}"]
      assert_equal find_text('%p.what= "Statistics for #{@name}"'), ["Statistics for \#{@name}"]
      assert_equal find_text('%p.what{:attr => :val}= "Statistics for #{@name}"'), ["Statistics for \#{@name}"]
    end
    
    
    
    
    
    # test "TODOS" do
    #   raise # make sure we test 
    #   # (1) html tags
    #   # 
    #   # %li= link_to "Support Dashboard", EY::Zendesk.gateway_url
    #   #  # this should work for passing in that ruby eval string as an arg to t('key', :name => name)
    #   
    #   # TODO when translating the text found to t() make sure to take into account duplicates of the same entry.
    # end

    private

    def find_text(haml)
      kinda_debug(haml) if ENV['DEBUG']
      find_text = FindText.new(haml)
      find_text.run
    end

    def kinda_debug(haml)
      begin
        6.times do puts ; end
        puts haml
        2.times do puts ; end
        r = Haml::Engine.new(haml).render
        puts r
        6.times do puts; end
      rescue => e
        puts e.message
      end
    end

  end
end