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
