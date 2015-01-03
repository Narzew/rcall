open($fargs[0]){|f|
x = f.read
if x.length == 0
	return 0
else
	return 1
end
}
