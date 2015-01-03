require 'fileutils'
require 'zlib'
require 'open-uri'
require 'thread'

$rcall_functions_config = "1,write,1,le_write
2,exit,0,le_exit
3,spacewrite,0,le_spacewrite
4,linewrite,0,le_linewrite
5,keywait,0,le_keywait
6,fwrite,1,le_fwrite
7,setvar,2,le_setvar
8,getvar,1,le_getvar
9,setglobal,1,le_setglobal
10,prompt,1,le_prompt
11,load,1,le_load
12,ruby,1,le_ruby
13,vareql,4,le_vareql
14,varneql,4,le_varneql
15,+,3,le_plus
16,-,3,le_minus
17,*,3,le_mul
18,/,3,le_div
19,%,3,le_modulo
20,^,3,le_xor
21,||,3,le_or
22,&&,3,le_and
23,f+,3,le_fplus
24,f-,3,le_fminus
25,f*,3,le_fmul
26,f/,3,le_fdiv
27,vartype,2,le_vartype
28,vargreater,4,le_vargreater
29,varlower,4,le_varlower
30,varfgreater,4,le_varfgreater
31,varflower,4,le_varflower
32,vargreatereql,4,le_vargreatereql
33,varlowereql,4,le_varlowereql
34,varfgreatereql,4,le_varfgreatereql
35,varflowereql,4,le_varflowereql
36,loadlib,1,le_loadlib
37,call,3,le_call
38,varcall,4,le_varcall
39,sleep,1,le_sleep
40,varsleep,1,le_varsleep
41,clearvar,1,le_clearvar
42,randomize,3,le_randomize
43,varrandomize,3,le_varrandomize
44,vardump,1,le_vardump
45,loadvar,1,le_loadvar
46,evalfile,1,le_evalfile
47,promptval,2,le_promptval
"
$compile = lambda{|x,y| File.open(x,'rb'){|f|$tmp=f.read}
	$result=[]
	$tmp.each_line{|x|next if x[0]=="#"||(x[0]=="/"&&x[1]=="/");eval($list_functions)}
	$tmp=nil
	File.open(y,'wb'){|f|f.write(Zlib::Deflate.deflate(Marshal.dump($result)))}
}.freeze
$interprete = lambda{|x|
	File.open(x,'rb'){|f|$result=Marshal.load(Zlib::Inflate.inflate(f.read))}
	$result.each{|x|$function_args,$function_data,x = x,x[0],x[1];eval($eval_functions)}
}.freeze
module RCall
	def self.prepare
		$list_functions = (RCall.generate_function_list).freeze
		$eval_functions = (RCall.generate_eval_list).freeze
		$globals = {}
		$variables = {}
		$libs = {}
		RCall::Functions.set_default_globals
	end
	def self.get_function_name(line)
		return line.split("\x20").at(0)
	end
	def self.get_argument(line,arg_id)
		return line.split("\x20").at(arg_id)
	end
	def self.get_arguments(line)
		return line.split("\x20").delete_at(0)
	end
	def self.get_command_and_arguments(line)
		return line.split("\x20")
	end
	def self.get_one_big_argument(line)
		return line.split("\x20").delete_at(0)
	end
	def self.generate_function_list
		s = ""
		s << "case RCall.get_function_name(x)\n"
		$rcall_functions_config.each_line {|x|
		y = x.split(',')
		s << "when \"#{y.at(1)}\" then $result << [#{y.at(0)}"
		mtcount = y.at(2).to_i
		if mtcount == 0
			s << "]\n"
		else
			mtcount.times{|x|
				s << ",RCall.get_argument(x,#{x+1})"
			}
			s << "]\n"
		end
		}
		s << "else\nraise\"Compile Error!\"\nend\n"
		return s
	end
	def self.generate_eval_list
		s = ""
		s << "case $function_data\n"
		$rcall_functions_config.each_line{|x|
		y = x.split(',')
		k = y.at(3).delete("\n")
		s << "when #{y.at(0)} then RCall::Functions.#{k}"
		mtcount = y.at(2).to_i
		if mtcount == 0
			s << "\n"
		else
			s << "("
			mtcount.times{|x|
			if x == mtcount-1
				s << "$function_args.at(#{x+1})"
			else
				s << "$function_args.at(#{x+1}),"
			end
			}
			s << ")\n"
		end
		}
		s << "else\nraise\"Invalid Command!\"\nend\n"
		return s
	end
end

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

module RCall
	module Library
		def self.extract_config(inp)
			file = File.open(inp,'rb')
			data = file.read
			file.close
			$result = []
			data.each_line{|x|
			a = x.split("\x20")
			$result << [a.at(0).gsub("\n",""),a.at(1).gsub("\n","")]
			}
			return $result
		end			
		def self.compile_library(inp,out)
			$libdata = RCall::Library.extract_config(inp)
			$result = [[],[],[],[]]
			$result[0] = 0
			$act_function = 0
			$libdata.each{|x|
				case x.at(0)
				when "libname"
						$result[1][0] = x.at(1)
				when "libauthor"
						$result[1][1] = x.at(1)
				when "libversion"
						$result[1][2] = x.at(1)
				when "functionid"
					$act_function = x.at(1).to_i
					$result[2][$act_function] = [] if $result[2][$act_function] == nil
					$result[2][$act_function][0] = $act_function
				when "functionname"
					$result[2][$act_function][1] = x.at(1)
					$result[3] << [x.at(1),$act_function]
				when "functionauthor"
					$result[2][$act_function][2] = x.at(1)
				when "functiontype"
					$result[2][$act_function][3] = x.at(1).to_i
				when "functioncode"
					file = File.open(x.at(1),'rb')
					$result[2][$act_function][4] = file.read
					file.close
				when "libend"
					break
				end
			}
			file = File.open(out, 'wb')
			file.write(Zlib::Deflate.deflate(Marshal.dump($result)))
			file.close
		end
	end
end

begin
	RCall.prepare
	case ARGV[0]
	when 'c'
		if ARGV[2] == nil
			$compile.call(ARGV[1], ARGV[1].gsub('.rcl','.rcc').gsub('.cll','.rcc'))
		else
			$compile.call(ARGV[1], ARGV[2])
		end
	when 'i'
		$interprete.call(ARGV[1])
	when 'l'
		if ARGV[2] == nil
			RCall::Library.compile_library(ARGV[1], ARGV[1].gsub('.lib','.rbl').gsub('.cfg','.rbl'))
		else
			RCall::Library.compile_library(ARGV[1],ARGV[2])
		end
	end
end

