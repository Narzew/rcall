require 'zlib'
module RCall
	module Generator
		def self.file_read(x)
			file = File.open(x,'rb')
			data = file.read
			file.close
			return data
		end
		def self.generate
			$result = ""
			$result << RCall::Generator.file_read('Modules/requirements.rb') << "\n"
			$result << "$rcall_functions_config = \"" << RCall::Generator.file_read('Modules/functions.conf') << "\"" << "\n"
			$result << RCall::Generator.file_read('Modules/main.rb') << "\n"
			$result << RCall::Generator.file_read('Modules/functions.rb') << "\n"
			$result << RCall::Generator.file_read('Modules/library.rb') << "\n"
			$result << RCall::Generator.file_read('Modules/argmain.rb') << "\n"
			file = File.open('rcall.rb','wb')
			file.write($result)
			file.close
		end
	end
end
begin
	RCall::Generator.generate
end
