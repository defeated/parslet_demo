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
pp parsed1.dig(:record, :bimi_data, :v).class

require 'uri'
class TxtTransform < Parslet::Transform
  rule(v: simple(:v)) { v.to_s }
  rule(l: simple(:l)) { URI.parse("https://example.com") }
  rule(record: subtree(:record)) do
    Struct.new("Record", :bimi_data, :location_data, keyword_init: true).new(record)
  end
end

transformed1 = TxtTransform.new.apply(parsed1)
pp transformed1
pp transformed1.bimi_data
pp transformed1.location_data
