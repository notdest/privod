rowsCount	= 80	-- настройки таблицы с индикаторами

updateInterval  = 300
eraseInterval	= 60000

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

colors 	= {
	green	= {light = RGB(29, 36, 27), medium = RGB(32, 54, 26), heavy = RGB(35, 74, 25) },
	red		= {light = RGB(55, 31, 31), medium = RGB(76, 35, 35), heavy = RGB(116, 41, 41) }
}






dofile (getScriptPath() .. "\\tradingFunctions.lua")

controlId = nil		-- айдишники таблиц
metricsId = nil

lastStop 		= 0
lastRealStop	= 0
stopQuantity	= 0
lastStopId		= 0

lastPrice       = 0
middle	  		= 0
contango  		= 0
curPos	  		= 0
openBuys		= 0
openSells		= 0
entryPrice		= 0
exitPrice		= 0
workingVolume	= 1
currentResult	= 0

f 		= nil

isRun 	= true

dofile (getScriptPath() .. "\\interfaceFunctions.lua")

	function OnStop()
		isRun = false
		if controlId ~= nil then
			DestroyTable(controlId)
		end
		if metricsId ~= nil then
			DestroyTable(metricsId)
		end

        f:flush()
        f:close()
	end

    function OnInit( path )
        f = io.open(getScriptPath() .. os.date("\\%Y-%m-%d.csv"), "a")
    end

	function OnStopOrder(order)
		if bit.band( order.flags, 1) == 0 then
			displayNoStop()
		end
	end

	partialDeals	= {} -- сделки, где исполнена только часть
	function OnOrder( order)

		if order.trans_id > 0 and order.balance < order.qty then					-- Эта сделака частично исполнена
			local oldBalance = order.qty
			if partialDeals[order.ordernum] ~= nil then
				oldBalance	= partialDeals[order.ordernum]
			end

			if oldBalance - order.balance > 0 then			-- если ее исполнили сейчас
				onRealOrder( order.price, oldBalance - order.balance, bit.band( order.flags, 4) ~= 0 )

				if order.balance > 0 and bit.band( order.flags, 1) ~= 0 then
					partialDeals[order.ordernum] = order.balance
				end
			end

			if 	(partialDeals[order.ordernum] ~= nil)	-- сделка исполнялась, но теперь не активна
				and (order.balance == 0 or bit.band( order.flags, 1) == 0) then
					partialDeals[order.ordernum] = nil
			end
		end


	end

	-- функция, которуя я вызываю, если мы действительно что-то купили или продали
	function onRealOrder( price, qty, isOffer )
		if isOffer then
			currentResult = currentResult + price*qty
			f:write(os.date("%X")..","..price..",-"..qty.."\n")
		else
			currentResult = currentResult - price*qty
			f:write(os.date("%X")..","..price..","..qty.."\n")
		end
        f:flush()


        lastPrice   = price
		if entryPrice == 0 then
			entryPrice = price
			SetCell(controlId, 4, 3, "Последняя: "..entryPrice )
		end
	end

	function OnQuote(class, sec )
		if     class == futures.class and sec == futures.sec then
			printQuotes()
		elseif class == share.class   and sec == share.sec   then
			printQuotes2()
		end
	end

	function OnTransReply(reply)
		if reply.status == 3 then
			if reply.trans_id == 108 then 		-- стопы с таким id, надо заменить на константы
				stopQuantity = reply.quantity
				lastStopId	 = reply.order_num
				SetCell(controlId, 2, 5, tostring(stopQuantity.." (снять)") )
			end
		end
	end

	event_table = {				-- это потом удалим
	[QTABLE_LBUTTONDOWN] 	= "Нажали левую кнопку мыши",
	[QTABLE_RBUTTONDOWN] 	= "Нажали правую кнопку мыши",
	[QTABLE_LBUTTONDBLCLK] 	= "Левый даблклик",
	[QTABLE_RBUTTONDBLCLK]	= "Правый даблклик",
	[QTABLE_SELCHANGED] 	= "Изменилась строка",
	[QTABLE_CHAR] 			= "Символьная клавиша",
	[QTABLE_VKEY] 			= "Еще какая-то клавиша",
	[QTABLE_CONTEXTMENU] 	= "Контекстное меню",
	[QTABLE_MBUTTONDOWN] 	= "Нажали на колесико мыши",
	[QTABLE_MBUTTONDBLCLK] 	= "Даблклик колесом",
	[QTABLE_LBUTTONUP] 		= "Отпустили левую кнопку мыши",
	[QTABLE_RBUTTONUP] 		= "Отпустили правую кнопку мыши",
	[QTABLE_CLOSE] 			= "Закрыли таблицу"
}



	function OnFuturesClientHolding( futPos)
		if futPos.sec_code == futures.sec then

			local lastPos 	= curPos

			curPos 		= futPos.totalnet
			openBuys	= futPos.openbuys
			openSells	= futPos.opensells

			if curPos == 0 then
				if lastStopId ~= 0 then
					dropStop(futures.class, lastStopId )
					displayNoStop()
				end

				if (openBuys ~= 0 or openSells ~= 0) and lastPos ~= curPos then
					dropLimit(futures.class,futures.assets)
				end

				SetCell(controlId, 4, 1, "Рез: "..currentResult )

				entryPrice = 0
				SetCell(controlId, 4, 3, "Последняя: "..entryPrice )

				SetColor(controlId, 2, 3, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
			elseif curPos > 0 then
				SetColor(controlId, 2, 3, colors.green.heavy, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
                if entryPrice == 0 then
                    entryPrice = lastPrice
                end
			elseif curPos < 0 then
				SetColor(controlId, 2, 3, colors.red.heavy, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
                if entryPrice == 0 then
                    entryPrice = lastPrice
                end
			end

			SetCell(controlId, 2, 3, tostring(curPos) )
			SetCell(controlId, 2, 4, "+"..openBuys..", -"..openSells.." (снять)" )

			if openBuys == 0 and openSells == 0 then
				exitPrice = 0
				SetCell(controlId, 4, 4, "Вых: "..exitPrice )
			end
		end
	end

	function controlCallback(t_id, msg, row, col)											-- функция, которая обрабатывает таблицу управления
		if     msg == QTABLE_LBUTTONDOWN then

			if     col == 1 then																-- Контанго
				if     row == 1 then
					addContango(1)
				elseif row == 3 then
					addContango(-1)
				elseif row == 4 then
					SetCell(controlId, 4, 1, "Рез: "..currentResult )
				end


			elseif col == 2 then																-- Рабочий объем
				if     row == 1 then
					workingVolume = workingVolume + 1
				elseif row == 3 then
					workingVolume = workingVolume - 1
				end
				SetCell(controlId, 2, 2, tostring(workingVolume) )


			elseif col == 3 then																-- Рыночные
				if     row == 1 then
					buyMarket( futures.class , futures.sec ,workingVolume)
				elseif row == 3 then
					sellMarket( futures.class , futures.sec ,workingVolume)
				end


			elseif col == 4 then
				if     row == 1 then															-- Лимитки
					local quotes = getQuoteLevel2 ( futures.class , futures.sec)
					exitPrice    = quotes.offer[1].price - 1
					sellLimit(futures.class , futures.sec ,workingVolume, exitPrice)
					SetCell(controlId, 4, 4, "Вых: "..exitPrice )
				elseif row == 2 then
					dropLimit(futures.class,futures.assets)
				elseif row == 3 then
					local quotes = getQuoteLevel2 ( futures.class , futures.sec)
					exitPrice    = quotes.bid[ math.floor(quotes.bid_count) ].price + 1
					buyLimit(futures.class , futures.sec ,workingVolume, exitPrice)
					SetCell(controlId, 4, 4, "Вых: "..exitPrice )
				end


			elseif col == 5 then																-- Стопы
				if     row == 2 then
					dropStop(futures.class, lastStopId )
					displayNoStop()
				end
			end

		elseif msg == QTABLE_MBUTTONDOWN then
			if     col == 1 then
				if     row == 1 then
					addContango(10)
				elseif row == 3 then
					addContango(-10)
				end
			end
		end
	end


	function metricsCallback(t_id, msg, row, col)											-- функция, которая обрабатывает таблицу с метриками
		local str = string.format("Метрики, %s, row = %d, col = %d", event_table[msg], row, col)
		message(str)

		if msg == QTABLE_LBUTTONDOWN then
			if    col == 3 then
				exitPrice    = middle + math.floor(rowsCount/2) - row
				buyLimit(futures.class , futures.sec ,workingVolume, exitPrice)
				SetCell(controlId, 4, 4, "Вых: "..exitPrice )
			elseif col == 4 then
				if lastStopId == 0 then
					lastStop  = middle + math.floor(rowsCount/2) - row
				end
			elseif col == 5 then
				exitPrice = middle + math.floor(rowsCount/2) - row
				sellLimit(futures.class , futures.sec ,workingVolume, exitPrice)
				SetCell(controlId, 4, 4, "Вых: "..exitPrice )
			end
		elseif msg == QTABLE_MBUTTONDOWN then
			local priceOfClick = middle + math.floor(rowsCount/2) - row
			if    col == 4 then
				if 	   exitPrice == priceOfClick then
					dropLimit(futures.class,futures.assets)

				elseif (priceOfClick >= lastStop and priceOfClick <= lastRealStop)
					or (priceOfClick <= lastStop and priceOfClick >= lastRealStop) then

					dropStop(futures.class, lastStopId )
					displayNoStop()
				end
			end
		elseif msg == QTABLE_LBUTTONUP then
			if col == 4 then
				if lastStopId == 0 then
					lastRealStop = middle + math.floor(rowsCount/2) - row
					if     lastRealStop > lastStop then
						buyStop(futures.class , futures.sec, math.abs(curPos), lastRealStop, lastStop)
					elseif lastRealStop < lastStop then
						sellStop(futures.class , futures.sec, math.abs(curPos), lastRealStop, lastStop)
					else
						lastRealStop = 0
						lastStop 	 = 0
					end
				end
			end
		elseif msg == QTABLE_VKEY then														-- Всякие клавиши
			if     col == 38 then													-- стрелка вверх, вход по рынку
				buyMarket( futures.class , futures.sec ,workingVolume)
			elseif col == 40 then													-- стрелка вниз, вход по рынку
				sellMarket( futures.class , futures.sec ,workingVolume)
			elseif col == 96 then													-- нуль на панели слева, отцентрировать стакан
				setMiddle()
			elseif col == 27 then													-- esc, снять лимитки и стопы
				if lastStopId ~= 0 then
					dropStop(futures.class, lastStopId )
					displayNoStop()
				end

				if openBuys ~= 0 or openSells ~= 0 then
					dropLimit(futures.class,futures.assets)
				end
			elseif col == 37 then													-- (стрелка влево) - заявка на выход, вне стакана
				local quotes = getQuoteLevel2 ( futures.class , futures.sec)
				if curPos > 0 then
					exitPrice    = quotes.offer[1].price - 1
					sellLimit(futures.class , futures.sec ,math.abs(curPos), exitPrice)
				elseif curPos < 0 then
					exitPrice    = quotes.bid[ math.floor(quotes.bid_count) ].price + 1
					buyLimit(futures.class , futures.sec ,math.abs(curPos), exitPrice)
				end
				SetCell(controlId, 4, 4, "Вых: "..exitPrice )
			elseif col == 46 then													-- del, всё снять, всюду выйти
				if lastStopId ~= 0 then
					dropStop(futures.class, lastStopId )
					displayNoStop()
				end

				if openBuys ~= 0 or openSells ~= 0 then
					dropLimit(futures.class,futures.assets)
				end

				if curPos > 0 then
					sellMarket( futures.class , futures.sec ,math.abs(curPos))
				elseif curPos < 0 then
					buyMarket( futures.class , futures.sec ,math.abs(curPos))
				end
			elseif col == 49 then													-- 1, установить объем
				workingVolume = 1
				SetCell(controlId, 2, 2, tostring(workingVolume) )
			elseif col == 50 then													-- 2, установить объем
				workingVolume = 2
				SetCell(controlId, 2, 2, tostring(workingVolume) )
			elseif col == 51 then													-- 3, установить объем
				workingVolume = 5
				SetCell(controlId, 2, 2, tostring(workingVolume) )
			elseif col == 52 then													-- 4, установить объем
				workingVolume = 10
				SetCell(controlId, 2, 2, tostring(workingVolume) )
			elseif col == 53 then													-- 5, установить объем
				workingVolume = 15
				SetCell(controlId, 2, 2, tostring(workingVolume) )
			end
		end
	end



	function OnAllTrade( trade )															-- Прилетела обезличенная сделка
		if     trade.class_code == futures.class and trade.sec_code == futures.sec then
			local row	= middle + math.floor(rowsCount/2) - trade.price
			if bit.band( trade.flags, 1) ~= 0 then
				addTrade(trade,row,2)
			else
				addTrade(trade,row,1)
			end
			addTrade(trade,row,1)
		elseif trade.class_code == share.class   and trade.sec_code == share.sec then
			local row	= middle + math.floor(rowsCount/2 - trade.price * 100) - contango
			if bit.band( trade.flags, 1) ~= 0 then
				addTrade(trade,row,7)
			else
				addTrade(trade,row,6)
			end
		end
	end

	function addTrade( trade,row,col )
		if row >= 1 and row <= rowsCount then
			local oldVal = GetCell(metricsId,row,col)

				if oldVal.image == "" then
					SetCell(metricsId,row,col,tostring(trade.qty))
				else
					SetCell(metricsId,row,col,tostring( tonumber(oldVal.image) + trade.qty))
				end

				if trade.flags == 1 then
					Highlight(metricsId, row, col, colors.red.heavy , QTABLE_DEFAULT_COLOR , 200)
				else
					Highlight(metricsId, row, col, colors.green.heavy, QTABLE_DEFAULT_COLOR , 200)
				end
		end
	end



	function printQuotes()
		quotes 			 = getQuoteLevel2 ( futures.class , futures.sec)
		endValue		 = middle + math.floor(rowsCount/2)
		local entryIndex = endValue - entryPrice

		

		for i = 1, rowsCount do 								-- выводим линейку у фьюча и очищаем его
			SetCell(metricsId, i, 4, tostring( endValue - i) )
			SetCell(metricsId, i, 3, '' )
			SetCell(metricsId, i, 5, '' )

			SetColor(metricsId, i, 3, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
			SetColor(metricsId, i, 4, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
			SetColor(metricsId, i, 5, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
		end

		for k, v in pairs(quotes.bid) do
			local index	= endValue - v.price
			if index >= 1 and index <= rowsCount then

					local color = colors.green.heavy
					if tonumber(v.quantity) < futures.volume.medium then
						color = colors.green.light
					elseif tonumber(v.quantity) < futures.volume.high then
						color = colors.green.medium
					end

				SetCell(metricsId, 	index, 3, tostring( v.quantity) )
				SetColor(metricsId, index, 3, color, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
				SetColor(metricsId, index, 4, color, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
			end
		end

		for k, v in pairs(quotes.offer) do
			index	= endValue - v.price
			if index >= 1 and index <= rowsCount then

					local color = colors.red.heavy
					if tonumber(v.quantity) < futures.volume.medium then
						color = colors.red.light
					elseif tonumber(v.quantity) < futures.volume.high then
						color = colors.red.medium
					end

				SetCell(metricsId, 	index, 5, tostring( v.quantity) )
				SetColor(metricsId, index, 5, color, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
				SetColor(metricsId, index, 4, color, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
			end
		end

		if entryIndex > 0 and entryIndex <= rowsCount then
			SetColor(metricsId, entryIndex, 4, RGB(177, 195, 59), QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
		end

		local exitIndex = endValue - exitPrice
		if exitIndex > 0 and exitIndex <= rowsCount then
			SetColor(metricsId, exitIndex, 4, RGB(0, 219, 216), QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
		end

		local stopIndexLow  = endValue - math.max(lastStop, lastRealStop)
		local stopIndexHigh = endValue - math.min(lastStop, lastRealStop)
		if stopIndexLow > 0 and stopIndexLow <= rowsCount and stopIndexHigh > 0 and stopIndexHigh <= rowsCount then
			for i = stopIndexLow, stopIndexHigh do
				SetColor(metricsId, i, 4, RGB(165, 0, 200), QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
			end
		end

	end


	function printQuotes2()
		quotes 			= getQuoteLevel2 ( share.class , share.sec)
		endValue		= middle + math.floor(rowsCount/2) - contango

		

		for i = 1, rowsCount do 								-- выводим линейку у фьюча и очищаем его
			SetCell(metricsId, i, 9, string.format("%01.2f", (endValue - i)/100 ) )
			SetCell(metricsId, i, 8, '' )
			SetCell(metricsId, i, 10, '' )

			SetColor(metricsId, i, 8, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
			SetColor(metricsId, i, 9, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
			SetColor(metricsId, i, 10, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
		end


		if tonumber(quotes.bid_count) > 0 then
			for k, v in pairs(quotes.bid) do
				local index	= endValue - math.floor(v.price * 100)
				if index >= 1 and index <= rowsCount then

					local color = colors.green.heavy
					if tonumber(v.quantity) < share.volume.medium then
						color = colors.green.light
					elseif tonumber(v.quantity) < share.volume.high then
						color = colors.green.medium
					end

					SetCell(metricsId, 	index, 8, tostring( v.quantity) )
					SetColor(metricsId, index, 8, color, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
					SetColor(metricsId, index, 9, color, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
				end
			end
		end

		if tonumber(quotes.offer_count) > 0 then
			for k, v in pairs(quotes.offer) do
				index	= endValue - math.floor(v.price * 100)
				if index >= 1 and index <= rowsCount then

					local color = colors.red.heavy
					if tonumber(v.quantity) < share.volume.medium then
						color = colors.red.light
					elseif tonumber(v.quantity) < share.volume.high then
						color = colors.red.medium
					end

					SetCell(metricsId, 	index, 10, tostring( v.quantity) )
					SetColor(metricsId, index, 10, color, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
					SetColor(metricsId, index, 9, color, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
				end
			end
		end
	end



	function main()
		controlId = AllocTable()															-- Создаем таблицу с элементами управления
		AddColumn(controlId, 1, "Контанго", 		true, QTABLE_CACHED_STRING_TYPE, 12)
		AddColumn(controlId, 2, "Рабочий объем",  	true, QTABLE_CACHED_STRING_TYPE, 17)
		AddColumn(controlId, 3, "Войти по рынку",  	true, QTABLE_CACHED_STRING_TYPE, 17)
		AddColumn(controlId, 4, "Выйти",			true, QTABLE_CACHED_STRING_TYPE, 12)
		AddColumn(controlId, 5, "Стопы",			true, QTABLE_CACHED_STRING_TYPE, 12)
		CreateWindow(controlId)


		data = {
			{"+ (++ cкм)", "Вверх", 				"Вверх",		"Сверху",			"" },
			{"0", 		   tostring(workingVolume), "0",			"+0, -0 (снять)",	""		 },
			{"- (-- cкм)", "Вниз", 					"Вниз",			"Снизу",			""  },
			{"Рез: 0", 	   "", 						"Последняя: 0",	"Вых: 0",			"Ручной" }
		}

		for k, v in pairs(data) do
			row = InsertRow(controlId, -1)
			SetCell(controlId, row, 1, v[1])
			SetCell(controlId, row, 2, v[2])
			SetCell(controlId, row, 3, v[3])
			SetCell(controlId, row, 4, v[4])
			SetCell(controlId, row, 5, v[5])
		end

		SetWindowCaption(controlId, "Управление")
		SetTableNotificationCallback(controlId, controlCallback)


		metricsId = AllocTable()															-- Создаем таблицу с стаканом
		AddColumn(metricsId, 1, "пок",		true, QTABLE_INT_TYPE, 7)
		AddColumn(metricsId, 2, "прод",		true, QTABLE_INT_TYPE, 7)
		AddColumn(metricsId, 3, "", 		true, QTABLE_INT_TYPE, 8)
		AddColumn(metricsId, 4, "Фьючерс",  true, QTABLE_INT_TYPE, 10)
		AddColumn(metricsId, 5, "", 		true, QTABLE_INT_TYPE, 8)
		AddColumn(metricsId, 6, "пок",  	true, QTABLE_INT_TYPE, 7)
		AddColumn(metricsId, 7, "прод",  	true, QTABLE_INT_TYPE, 7)
		AddColumn(metricsId, 8, "", 		true, QTABLE_INT_TYPE, 8)
		AddColumn(metricsId, 9, "Акция",  	true, QTABLE_INT_TYPE, 10)
		AddColumn(metricsId, 10, "", 		true, QTABLE_INT_TYPE, 8)
		CreateWindow(metricsId)


		for i = 1, rowsCount do
			row = InsertRow(metricsId, -1)
		end

		SetWindowCaption(metricsId, "Стаканы")
		SetTableNotificationCallback(metricsId, metricsCallback)

		SetWindowPos(controlId,280,550,470,140)
		SetWindowPos(metricsId,749,0,555,893)

		local quotesF = getQuoteLevel2 ( futures.class , futures.sec)
		local quotesS = getQuoteLevel2 ( share.class   , share.sec)
		if tonumber(quotesF.offer_count) > 0 and tonumber(quotesS.offer_count) > 0 then
			addContango( quotesF.offer[1].price - quotesS.offer[1].price*100)
		end

		setMiddle()								-- Заполняем таблицу
		
		local lastErase = 0
		while isRun do
			if lastErase >= eraseInterval then
				lastErase	= 0
				clearTrades()
			end

			lastErase = lastErase + updateInterval
			sleep(updateInterval)
		end
	end