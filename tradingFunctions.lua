tradingAccount	= "SPBFUT009HF"
clientCode		= "SPBFUT00390/"



function buyMarket(class, sec, count)
	local quotes	= getQuoteLevel2 ( class , sec)
	local price 	= tostring( quotes.offer[1].price )

	local transaction = {
		TRANS_ID				= "4",
		CLASSCODE				= class,
		ACTION					= "Ввод заявки",
		["Торговый счет"]		= tradingAccount,
		["К/П"] 				= "Покупка",
		["Тип"]					= "Рыночная",
		["Класс"]				= class,
		["Инструмент"]			= sec,
		["Цена"]				= price,
		["Количество"]			= tostring(count),
		["Условие исполнения"]	= "Поставить в очередь",
		["Комментарий"]			= clientCode,
		["Переносить заявку"]	= "Нет",
		["Дата экспирации"]		= os.date("%Y%m%d")
	}

	return sendTransaction(transaction)
end


function sellMarket(class, sec, count)
	local quotes	= getQuoteLevel2 ( class , sec)
	local price 	= tostring( quotes.bid[ math.floor(quotes.bid_count) ].price )

	local transaction = {
		TRANS_ID				= "5",
		CLASSCODE				= class,
		ACTION					= "Ввод заявки",
		["Торговый счет"]		= tradingAccount,
		["К/П"] 				= "Продажа",
		["Тип"]					= "Рыночная",
		["Класс"]				= class,
		["Инструмент"]			= sec,
		["Цена"]				= price,
		["Количество"]			= tostring(count),
		["Условие исполнения"]	= "Поставить в очередь",
		["Комментарий"]			= clientCode,
		["Переносить заявку"]	= "Нет",
		["Дата экспирации"]		= os.date("%Y%m%d")
	}

	return sendTransaction(transaction)
end



function buyLimit(class, sec, count, price)
	transaction = {
		TRANS_ID				= "4",
		CLASSCODE				= class,
		ACTION					= "Ввод заявки",
		["Торговый счет"]		= tradingAccount,
		["К/П"] 				= "Покупка",
		["Тип"]					= "Лимитированная",
		["Класс"]				= class,
		["Инструмент"]			= sec,
		["Цена"]				= tostring(price),
		["Количество"]			= tostring(count),
		["Условие исполнения"]	= "Поставить в очередь",
		["Комментарий"]			= clientCode,
		["Переносить заявку"]	= "Нет",
		["Дата экспирации"]		= os.date("%Y%m%d")
	}

	return sendTransaction(transaction)
end


function sellLimit(class, sec, count, price)
	transaction = {
		TRANS_ID				= "5",
		CLASSCODE				= class,
		ACTION					= "Ввод заявки",
		["Торговый счет"]		= tradingAccount,
		["К/П"] 				= "Продажа",
		["Тип"]					= "Лимитированная",
		["Класс"]				= class,
		["Инструмент"]			= sec,
		["Цена"]				= tostring(price),
		["Количество"]			= tostring(count),
		["Условие исполнения"]	= "Поставить в очередь",
		["Комментарий"]			= clientCode,
		["Переносить заявку"]	= "Нет",
		["Дата экспирации"]		= os.date("%Y%m%d")
	}

	return sendTransaction(transaction)
end