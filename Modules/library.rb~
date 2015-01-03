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
