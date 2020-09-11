futures		= {	class 	= "SPBFUT",
				sec 	= "SRU0",
				assets	= "SBRF",
				volume 	= {
					medium 	= 10,
					high 	= 100
				}
}
share		= {	class 	= "QJSIM",
				sec 	= "SBER",
				volume 	= {
					medium 	= 100,
					high 	= 1000
				}
}


tradingAccount	= "SPBFUT0008n"
clientCode		= "10265/"
firmId 			= "SPBFUT000000"

dofile (getScriptPath() .. "\\src\\privod.lua")