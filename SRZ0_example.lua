
futures		= {	class 	= "SPBFUT",
				sec 	= "SRZ0",
				assets	= "SBRF", 	-- это нужно для снятия стопов. В кармане сохранить "снять стоп-заявки", там где-то было
				volume 	= {
					medium 	= 10,	-- это влияет на цвет подсветки
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


tradingAccount	= "A222HZP"			-- можно сохранить карман сделок и взять оттуда
clientCode		= "7LЕCY/"


firmId 			= "SPBFUT001"		-- я это брал из сделок, вставлял printArray(order) в OnOrder(). 
									-- без этого параметра не будет работать, если позиция на начало дня не 0



dofile (getScriptPath() .. "\\src\\privod.lua")  -- подключаем файл с приводом, чтобы всё работало