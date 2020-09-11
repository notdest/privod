
futures		= {	class 	= "SPBFUT",
				sec 	= "SRU0",
				assets	= "SBRF",
				volume 	= {
					medium 	= 10,
					high 	= 100
				}
}
share		= {	class 	= "TQBR",
				sec 	= "SBER",
				volume 	= {
					medium 	= 100,
					high 	= 1000
				}
}


tradingAccount	= "A709HZP"
clientCode		= "4LUCY/"
firmId 			= "SPBFUT01"

dofile (getScriptPath() .. "\\src\\privod.lua")