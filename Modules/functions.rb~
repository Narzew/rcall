module RCall::Functions
	def self.do_nothing
	end
	def self.set_default_globals
		$globals['promptval'] = "Enter a valid value.\n"
	end
	def self.le_write(x)
		print x
	end
	def self.le_exit
		exit
	end
	def self.le_spacewrite
		print " "
	end
	def self.le_linewrite
		print "\n"
	end
	def self.le_keywait
		$stdin.gets
	end
	def self.le_fwrite(x)
		print x.gsub!("+", " ")
	end
	def self.le_setvar(x,y)
		$variables[x] = y
	end
	def self.le_getvar(x)
		print $variables[x]
	end
	def self.le_setglobal(x,y)
		$global[x] = y
	end
	def self.le_prompt(x)
		$variables[x] = $stdin.gets.chomp!
	end
	def self.le_load(x)
		$interprete.call(x)
	end
	def self.le_ruby(x)
		file = File.open(x,'rb')
		data = file.read
		file.close
		eval(data)
	end
	def self.le_vareql(x,y,z,a)
		if $variables[x] == $variables[y]
			RCall::Functions.le_load(z)
		elsif a != nil
			RCall::Functions.le_load(a)
		end
	end
	def self.le_varneql(x,y,z,a)
		if $variables[x] != $variables[y]
			RCall::Functions.le_load(z)
		elsif a != nil
			RCall::Functions.le_load(a)
		end
	end
	def self.le_plus(x,y,z)
		$variables[x] = $variables[y].to_i + $variables[z].to_i
	end
	def self.le_minus(x,y,z)
		$variables[x] = $variables[y].to_i - $variables[z].to_i
	end
	def self.le_mul(x,y,z)
		$variables[x] = $variables[y].to_i * $variables[z].to_i
	end
	def self.le_div(x,y,z)
		$variables[x] = $variables[y].to_i / $variables[z].to_i
	end
	def self.le_modulo(x,y,z)
		$variables[x] = $variables[y].to_i % $variables[z].to_i
	end
	def self.le_xor(x,y,z)
		$variables[x] = $variables[y].to_i * $variables[z].to_i
	end
	def self.le_or(x,y,z)
		$variables[x] = $variables[y].to_i / $variables[z].to_i
	end
	def self.le_and(x,y,z)
		$variables[x] = $variables[y].to_i % $variables[z].to_i
	end
	def self.le_fplus(x,y,z)
		$variables[x] = $variables[y].to_f + $variables[z].to_f
	end
	def self.le_fminus(x,y,z)
		$variables[x] = $variables[y].to_f - $variables[z].to_f
	end
	def self.le_fmul(x,y,z)
		$variables[x] = $variables[y].to_f * $variables[z].to_f
	end
	def self.le_fdiv(x,y,z)
		$variables[x] = $variables[y].to_f / $variables[z].to_f
	end
	def self.le_vartype(x,y)
		case y
		when 'int' || 'i'
			$variables[x] = $variables[x].to_i
		when 'float' || 'f'
			$variables[x] = $variables[x].to_f
		when 'string' || 's'
			$variables[x] = $variables[x].to_s
		when 'array' || 'a'
			$variables[x] = $variables[x].to_a
		end
	end
	def self.le_vargreater(x,y,z,a)
		if $variables[x].to_i > $variables[y].to_i
			RCall::Functions.le_load(z)
		elsif a != nil
			RCall::Functions.le_load(a)
		end
	end
	def self.le_varlower(x,y,z,a)
		if $variables[x].to_i < $variables[y].to_i
			RCall::Functions.le_load(z)
		elsif a != nil
			RCall::Functions.le_load(a)
		end
	end
	def self.le_varfgreater(x,y,z,a)
		if $variables[x] > $variables[y]
			RCall::Functions.le_load(z)
		elsif a != nil
			RCall::Functions.le_load(a)
		end
	end
	def self.le_varflower(x,y,z,a)
		if $variables[x] < $variables[y]
			RCall::Functions.le_load(z)
		elsif a != nil
			RCall::Functions.le_load(a)
		end
	end
	def self.le_vargreatereql(x,y,z,a)
		if $variables[x].to_i >= $variables[y].to_i
			RCall::Functions.le_load(z)
		elsif a != nil
			RCall::Functions.le_load(a)
		end
	end
	def self.le_varlowereql(x,y,z,a)
		if $variables[x].to_i <= $variables[y].to_i
			RCall::Functions.le_load(z)
		elsif a != nil
			RCall::Functions.le_load(a)
		end
	end
	def self.le_varfgreatereql(x,y,z,a)
		if $variables[x] >= $variables[y]
			RCall::Functions.le_load(z)
		elsif a != nil
			RCall::Functions.le_load(a)
		end
	end
	def self.le_varflowereql(x,y,z,a)
		if $variables[x].to_f <= $variables[y].to_f
			RCall::Functions.le_load(z)
		elsif a != nil
			RCall::Functions.le_load(a)
		end
	end
	def self.le_parse_args(args) #private
		$fargs = []
		args.split(",").each{|x| $fargs << $variables[x] }
	end
	def self.le_loadlib(x)
		file = File.open(x, 'rb')
		$result = Marshal.load(Zlib::Inflate.inflate(file.read))
		file.close
		libname = $result[1][0].to_s
		$libs[libname] = {}
		$result.at(3).each{|x|
			$libs[libname][x[0].to_s] = [$result[2][x[1]][3],$result[2][x[1]][4]]
		}
	end
	def self.le_call(x,y,args)
		RCall::Functions.le_parse_args(args)
		if $libs[x][y][0] == 0
			eval($libs[x][y][1])
		elsif $libs[x][y][0] == 1
			eval("Thread.new { $interprete.call($libs[x][y][1]) }")
		end
	end
	def self.le_varcall(var,x,y,args)
		$variables[var] = RCall::Functions.le_call(x,y,args)
	end
	def self.le_sleep(x)
		sleep x.to_f
	end
	def self.le_varsleep(x)
		sleep($variables[x].to_f)
	end
	def self.le_clearvar(x)
		$variables[x] = nil
	end
	def self.le_randomize(x, min, max)
   		$variables[x] = rand(max.to_i - min.to_i + 1)
 	end
	def self.le_varrandomize(x, min, max)
		$variables[x] = rand($variables[max].to_i - $variables[min].to_i + 1)
	end
	def self.le_vardump(x)
		file = File.open($variables[x], 'wb')
		file.write(Zlib::Deflate.deflate(Marshal.dump($variables)))
		file.close
	end
	def self.le_loadvar(x)
		file = File.open($variables[x], 'rb')
		$variables = Marshal.load(Zlib::Inflate.inflate(file.read))
		file.close
	end
	def self.le_evalfile(x)
		file = File.open($variables[x],'rb')
		data = file.read
		file.close
		$interprete.call($variables[x])
	end
	def self.le_promptval(x,y)
		val = $stdin.gets.chomp.to_i
		while val > y.to_i
			puts $globals['promptval']
			val = $stdin.gets.chomp.to_i
		end
		$variables[x] = val
	end
end
