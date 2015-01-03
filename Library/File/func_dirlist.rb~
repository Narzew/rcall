$tmp = []
$tmp[0] = Dir.entries($fargs[0])
$tmp[1] = ""
$tmp[0].each{|p|
	next if p == '.'
	next if p == '..'
	$tmp[1] = $tmp[1] << "#{p}\n"
}
return $tmp[1].to_s
