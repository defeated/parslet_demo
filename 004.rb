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
    str('v') >>
    match[' \t'].maybe >> str('=') >> match[' \t'].maybe >>
    match['[:alnum:]'].repeat >>
    match[' \t'].maybe >> str(';').maybe >> match[' \t'].maybe >>

    str('l') >>
    match[' \t'].maybe >> str('=') >> match[' \t'].maybe >>
    match['[:alnum:]'].repeat >>
    match[' \t'].maybe >> str(';').maybe >> match[' \t'].maybe
  end
end

parsed = TxtParser.new.parse(txt1)
puts parsed
pp parsed
pp parsed.class
