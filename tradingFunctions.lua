tradingAccount	= "SPBFUT002T9"
clientCode		= "SPBFUT002T9/"



function buyMarket(class, sec, count)
	local quotes	= getQuoteLevel2 ( class , sec)
	local result 	= ""

	local transaction = {
		TRANS_ID				= "104",
		CLASSCODE				= class,
		ACTION					= "Ввод заявки",
		["Торговый счет"]		= tradingAccount,
		["К/П"] 				= "Покупка",
		["Тип"]					= "Рыночная",
		["Класс"]				= class,
		["Инструмент"]			= sec,
		["Цена"]				= '',
		["Количество"]			= tostring(count),
		["Условие исполнения"]	= "Поставить в очередь",
		["Комментарий"]			= clientCode,
		["Переносить заявку"]	= "Нет",
		["Дата экспирации"]		= os.date("%Y%m%d")
	}

	for i = 1, tonumber(quotes.offer_count) do
		transaction['Цена']	= tostring(quotes.offer[i].price)

		if tonumber(quotes.offer[i].quantity) >= count then
			transaction['Количество']	= tostring(count)
			result	= sendTransaction(transaction)
			break
		else
			transaction['Количество']	= tostring(quotes.offer[i].quantity)
			result	= sendTransaction(transaction)
			count 	= count - quotes.offer[i].quantity
		end

		if result ~= "" then
			message("Сбой транзакции: "..result)
		end
	end

	return tonumber(transaction['Цена'])
end


function sellMarket(class, sec, count)
	local quotes	= getQuoteLevel2 ( class , sec)
	local result 	= ""

	local transaction = {
		TRANS_ID				= "105",
		CLASSCODE				= class,
		ACTION					= "Ввод заявки",
		["Торговый счет"]		= tradingAccount,
		["К/П"] 				= "Продажа",
		["Тип"]					= "Рыночная",
		["Класс"]				= class,
		["Инструмент"]			= sec,
		["Цена"]				= '',
		["Количество"]			= tostring(count),
		["Условие исполнения"]	= "Поставить в очередь",
		["Комментарий"]			= clientCode,
		["Переносить заявку"]	= "Нет",
		["Дата экспирации"]		= os.date("%Y%m%d")
	}


	for i = tonumber(quotes.bid_count),1, -1 do
		transaction['Цена']	= tostring(quotes.bid[i].price)

		if tonumber(quotes.bid[i].quantity) >= count then
			transaction['Количество']	= tostring(count)
			result	= sendTransaction(transaction)
			break
		else
			transaction['Количество']	= tostring(quotes.bid[i].quantity)
			result	= sendTransaction(transaction)
			count 	= count - quotes.bid[i].quantity
		end

		if result ~= "" then
			message("Сбой транзакции: "..result)
		end
	end

	return tonumber(transaction['Цена'])
end



function buyLimit(class, sec, count, price)
	local transaction = {
		TRANS_ID				= "104",
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
	local transaction = {
		TRANS_ID				= "105",
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


function dropLimit(class,assets)
	local transaction = {
		TRANS_ID				= "104",
		CLASSCODE				= class,
		ACTION					= "Удалить все заявки по условию",
		["Торговый счет"]		= tradingAccount,
		["Направленность"] 		= "Все",
		["Тип заявки"]			= "Все",
		["Базовый актив"]		= assets
	}

	return sendTransaction(transaction)
end


-- Возвращает цену и стоп-цену стопа сверху
function calculateStopUp( quotes )
	local price,stopPrice, gap = 0,0,0
	local i = 1
	for i = 1, tonumber(quotes.offer_count) do

		if i > 3 and tonumber(quotes.offer[i].quantity) > 15 and stopPrice == 0 then  -- ищем стоп цену минимум в 3х позициаях от спреда и не меньше 15
			stopPrice = quotes.offer[i].price
		end

		if stopPrice ~= 0 then														  -- теперь ищем просто цену, на 4 позиции выше стоп-цены
			if gap < 4 then
				gap = gap + 1
			else
				price = quotes.offer[i].price
				break
			end
		end
	end

	if stopPrice == 0 then				-- перестраховка, если алгоритм не сработал
		stopPrice = quotes.offer[math.floor(tonumber(quotes.offer_count)/2)].price
		message("Стоп-цена вычислена аварийно")
	end

	if price == 0 then
		message("Цена стопа вычислена аварийно")
		price = quotes.offer[tonumber(quotes.offer_count)].price
	end

	return price,stopPrice
end

-- Возвращает цену и стоп-цену стопа снизу
function calculateStopDown( quotes )
	local price,stopPrice, gap = 0,0,0
	local bidCount = tonumber(quotes.bid_count)
	local i = 1
	for i = bidCount,1, -1 do

		if i < (bidCount-3) and tonumber(quotes.bid[i].quantity) > 15 and stopPrice == 0 then  -- ищем стоп цену минимум в 3х позициаях от спреда и не меньше 15
			stopPrice = quotes.bid[i].price
		end

		if stopPrice ~= 0 then														  -- теперь ищем просто цену, на 4 позиции выше стоп-цены
			if gap < 4 then
				gap = gap + 1
			else
				price = quotes.bid[i].price
				break
			end
		end
	end

	if stopPrice == 0 then				-- перестраховка, если алгоритм не сработал
		stopPrice = quotes.bid[math.floor(bidCount/2)].price
		message("Стоп-цена вычислена аварийно")
	end

	if price == 0 then
		message("Цена стопа вычислена аварийно")
		price = quotes.bid[1].price
	end

	return price,stopPrice
end

function buyStop(class, sec, count, price, stopPrice)
	transaction = {
		TRANS_ID				= "108",
		CLASSCODE				= class,
		ACTION					= "Стоп-заявка",
		["Тип стоп-заявки"] 	= "Стоп-лимит",
		["Действует по"] 		= "-1",
		["Торговый счет"]		= tradingAccount,
		["К/П"] 				= "Купля",
		["Условие"] 			= ">=",
		["Стоп-цена"] 			= tostring(stopPrice),
		["Флаги"] 				= "2",
		["Режим"] 				= class,
		["Инструмент"] 			= sec,
		["Бумага заявки"] 		= sec,
		["Класс заявки"]		= class,
		["Цена"]				= tostring(price),
		["Количество"]			= tostring(count),
		["Примечание"]			= clientCode,
		["Цена лим. заявки"]	= "0",
		["Отступ"]				= "0,000000",
		["Защ. спред"]			= "0,000000",
		["Номер баз. заявки"]	= "0",
		["Активна с"]			= "0",
		["Активна по"]			= "235959",
		["Стоп-цена2"]			= "0",
	}

	return sendTransaction(transaction)
end


function sellStop(class, sec, count, price, stopPrice)
	transaction = {
		TRANS_ID				= "108",
		CLASSCODE				= class,
		ACTION					= "Стоп-заявка",
		["Тип стоп-заявки"] 	= "Стоп-лимит",
		["Действует по"] 		= "-1",
		["Торговый счет"]		= tradingAccount,
		["К/П"] 				= "Продажа",
		["Условие"] 			= "<=",
		["Стоп-цена"] 			= tostring(stopPrice),
		["Флаги"] 				= "2",
		["Режим"] 				= class,
		["Инструмент"] 			= sec,
		["Бумага заявки"] 		= sec,
		["Класс заявки"]		= class,
		["Цена"]				= tostring(price),
		["Количество"]			= tostring(count),
		["Примечание"]			= clientCode,
		["Цена лим. заявки"]	= "0",
		["Отступ"]				= "0,000000",
		["Защ. спред"]			= "0,000000",
		["Номер баз. заявки"]	= "0",
		["Активна с"]			= "0",
		["Активна по"]			= "235959",
		["Стоп-цена2"]			= "0",
	}

	return sendTransaction(transaction)
end

function dropStop(class, id )
	transaction = {
		TRANS_ID				= "101",
		CLASSCODE				= class,
		ACTION					= "Снять стоп-заявку",
		["Номер Стоп-Заявки"] 	= tostring(id),
	}

	return sendTransaction(transaction)
end