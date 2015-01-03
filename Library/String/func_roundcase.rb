result = ''
count = 0
$fargs[0].each_char{|z|
result << z.upcase if count%2==0
result << z.downcase if count%2==1
count += 1
}
return result
