open($fargs[0]){|f|
x = f.read
if x.length == 0
	return 1
else
	return 0
end
}
