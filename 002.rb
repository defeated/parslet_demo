txt1 = 'v=BIMI1; l=https://example.com/i.svg'
pp txt1

array1 = txt1.split(';')
pp array1

array2 = txt1.split(';').map { |field| field.strip }
pp array2

array3 = txt1.split(';').map do |field|
  field.strip.split('=').map { |item| item }
end
pp array3

pp array3.to_h
