class FindText
  def initialize(haml)
    @haml = haml
  end

  def run
    match = @haml.rstrip.scan(/(([ \t]+)?(.*?))(?:\Z|\r\n|\r|\n)/m)
    match.pop
    @template = match.each_with_index.map do |(full, whitespace, text), index|
      Haml::Parser::Line.new(whitespace, text.rstrip, full, index, self, false)
    end
    result = []
    @template.map{|line|
      if txt = plain_text?(line)
        result << txt
      end
     }.compact
  end

  THINGS_THAT_ARE_NOT_TEXT = [ Haml::Parser::DIV_CLASS, Haml::Parser::DIV_ID, Haml::Parser::ELEMENT,
      Haml::Parser::COMMENT, Haml::Parser::SANITIZE, Haml::Parser::SCRIPT, Haml::Parser::FLAT_SCRIPT,
      Haml::Parser::SILENT_SCRIPT, Haml::Parser::FILTER, Haml::Parser::DOCTYPE, Haml::Parser::ESCAPE ]

  def plain_text?(line)
    case line.text[0]
    when *THINGS_THAT_ARE_NOT_TEXT
      nil
    else
      line.text
    end
  end
end