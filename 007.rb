require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'parslet'
end

txt1 = 'v=BIMI1; l=uri'
pp txt1

class TxtParser < Parslet::Parser
  root :record

  rule :record do
    (
      bimi_data.as(:bimi_data) >>
      location_data.as(:location_data)
    ).as(:record)
  end

  rule :bimi_data do
    str('v') >> item_separator >> match['[:alnum:]'].repeat.as(:v) >> field_separator
  end

  rule :location_data do
    str('l') >> item_separator >> match['[:alnum:]'].repeat.as(:l) >> field_separator
  end

  # helpers
  rule(:space?) { match[' \t'].maybe }
  rule(:item_separator) { space? >> str('=') >> space? }
  rule(:field_separator) { space? >> str(';').maybe >> space? }
end

parsed1 = TxtParser.new.parse(txt1)
pp parsed1

txt2 = 'v = BIMI1 ; l = uri'
pp txt2

parsed2 = TxtParser.new.parse(txt2)
pp parsed2
