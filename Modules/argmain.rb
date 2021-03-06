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
