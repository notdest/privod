
	function clearTrades()
		for i = 1, rowsCount do
			SetCell(metricsId, i, 1, '' )
			SetCell(metricsId, i, 5, '' )
		end
	end

	function setMiddle()
		quotes = getQuoteLevel2 ( futures.class , futures.sec)
		middle = math.ceil(  (quotes.offer[1].price + quotes.bid[ math.floor(quotes.bid_count) ].price )/2  )
		clearTrades()
		printQuotes()
		printQuotes2()
	end

	function addContango(step)
		contango = contango + step
		SetCell(controlId, 2, 1, tostring(contango) )
		printQuotes2()
		clearTrades()
	end

	function displayNoStop()
		stopQuantity = 0
		lastStopId	 = 0
		lastStop 	 = 0
		lastRealStop = 0
		SetCell(controlId, 2, 5, tostring(stopQuantity.." (снять)") )
	end



--  отладочные функции

	function printArray( arr )
		message("      ")
		for k, v in pairs(arr) do
			if type(v) == "table" then
				message(k..": таблица")
			else
				message(k..": "..v)
			end
		end
		message("      ")
	end