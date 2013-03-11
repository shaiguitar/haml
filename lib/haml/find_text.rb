class FindText

  def initialize(haml)
    @parser = Haml::Parser.new(haml, Haml::Options.new)
  end

  def run
    template = @parser.instance_variable_get(:@template) # HAX copy over Haml::Parser.new way of doing it instead of relying on internals
    result = []
    template.each{|line|
      if txt = plain_text(line)
        result << txt
      end
     }
     result.compact
  end

  THINGS_THAT_ARE_NOT_TEXT = [ Haml::Parser::DIV_CLASS, Haml::Parser::DIV_ID,
      Haml::Parser::COMMENT, Haml::Parser::SANITIZE, Haml::Parser::FLAT_SCRIPT,
      Haml::Parser::FILTER, Haml::Parser::DOCTYPE, Haml::Parser::ESCAPE ]

  ## hint: Use http://rubular.com
  SIMPLE_STRING_REGEX = /["'](.*)["']/
  # = "yes"
  # = 'yes'
  LINK_TO_REGEX = /link_to\s*\(?\s*['"](.*)['"]\s*,\s*(.*)\)?/
  # = link_to "yes", "http://bla.com"
  # = link_to('yes'    , "http://bla.com")
  # = link_to(  "yes's w space", "http://bla.com")
  ELEMENT_REGEX = /%([\w.#-]+)({.+?})?(=)?(.*)/
  # %foo.bar yes
  # %foo.bar= no
  # %foo{:a => 'b'} yes
  # rubular.com against %foo#bar#cheez{:cheeze => 'hell'}= "what #{var}"
  
  def plain_text(line)
    case line.text[0]
    when *THINGS_THAT_ARE_NOT_TEXT
      nil
    when Haml::Parser::SILENT_SCRIPT
      parse_silent_script(line)
    when Haml::Parser::ELEMENT
      parse_element(line)
    when Haml::Parser::SCRIPT
      parse_loud_script(line)
    else
      line.text
    end
  end
  
  private

  def parse_silent_script(line)
    line.text.match(/-[\s\t]*#{SIMPLE_STRING_REGEX}/) && $1
  end
  
  def parse_loud_script(line)
    line.text.match(/=[\s\t]*#{LINK_TO_REGEX}/)
    return $1 if text = $1
    line.text.match(/=[\s\t]*#{SIMPLE_STRING_REGEX}/)
    return $1
  end
  
  def parse_element(line)
    line.text.match(ELEMENT_REGEX)
    elem_with_class_and_ids = $1
    attributes_ruby_style = $2
    is_loud_script = $3
    text = $4
    if is_loud_script
      parser = Haml::Parser.new("= #{text}", Haml::Options.new)
      parse_loud_script(parser.instance_variable_get(:@template).first) # just treat it like a loud script
    else
      text.strip
    end
  end
  
end
