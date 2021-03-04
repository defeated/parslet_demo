require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'parslet'
  gem 'minitest'
end

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
  rule(:space?) { match[' \t'].repeat }
  rule(:item_separator) { space? >> str('=') >> space? }
  rule(:field_separator) { space? >> str(';').maybe >> space? }
end

require 'uri'
class TxtTransform < Parslet::Transform
  rule(v: simple(:v)) { v.to_s }
  rule(l: simple(:l)) { URI.parse("https://example.com") }
  rule(record: subtree(:record)) do
    Struct.new("Record", :bimi_data, :location_data, keyword_init: true).new(record)
  end
end

require 'minitest/autorun'
require 'minitest/pride'
require 'parslet/convenience'

class TxtTest < Minitest::Test
  def test_can_parse_bimi_data
    parser = TxtParser.new.bimi_data
    expected = { v: 'BIMI1' }

    tree = parser.parse_with_debug 'v=BIMI1;'
    assert_equal tree, expected

    tree = parser.parse_with_debug 'v = BIMI1 ;'
    assert_equal tree, expected

    tree = parser.parse_with_debug 'f=BIMI1;'
    assert_nil tree
  end

  def test_can_parse_bimi_data_with_spaces
    parser = TxtParser.new.bimi_data
    expected = { v: 'BIMI1' }

    tree = parser.parse_with_debug 'v  =   BIMI1 ;'
    assert_equal tree, expected
  end
end
