file = File.open($fargs[1],'wb')
open($fargs[0]){|f| data = f.read; file.write(data); file.close }
