rowsCount	= 80	-- ��������� ������� � ������������

futures		= {class = "SPBFUT", sec = "SRM0"}
share		= {class = "TQBR"  , sec = "SBER"}

controlId = nil		-- ��������� ������
metricsId = nil

middle	  = 0
contango  = 0

isRun 	  = true

	function OnStop()
		isRun = false
		if controlId ~= nil then
			DestroyTable(controlId)
		end
		if metricsId ~= nil then
			DestroyTable(metricsId)
		end
	end

	function OnQuote(class, sec )
		if     class == futures.class and sec == futures.sec then
			printQuotes()
		elseif class == share.class   and sec == share.sec   then
			printQuotes2()
		end
	end

	event_table = {				-- ��� ����� ������
	[QTABLE_LBUTTONDOWN] 	= "������ ����� ������ ����",
	[QTABLE_RBUTTONDOWN] 	= "������ ������ ������ ����",
	[QTABLE_LBUTTONDBLCLK] 	= "����� ��������",
	[QTABLE_RBUTTONDBLCLK]	= "������ ��������",
	[QTABLE_SELCHANGED] 	= "���������� ������",
	[QTABLE_CHAR] 			= "���������� �������",
	[QTABLE_VKEY] 			= "��� �����-�� �������",
	[QTABLE_CONTEXTMENU] 	= "����������� ����",
	[QTABLE_MBUTTONDOWN] 	= "������ �� �������� ����",
	[QTABLE_MBUTTONDBLCLK] 	= "�������� �������",
	[QTABLE_LBUTTONUP] 		= "��������� ����� ������ ����",
	[QTABLE_RBUTTONUP] 		= "��������� ������ ������ ����",
	[QTABLE_CLOSE] 			= "������� �������"
}

	function clearTrades()
		for i = 1, rowsCount do
			SetCell(metricsId, i, 1, '' )
			SetCell(metricsId, i, 5, '' )
		end
	end

	function controlCallback(t_id, msg, row, col)											-- �������, ������� ������������ ������� ����������
		if msg == QTABLE_LBUTTONDOWN then
			if row == 1 then

				if col == 1 then
					addContango(1)
				elseif col == 3 then
					setMiddle()
				end
			elseif row == 2 then
				if col == 3 then
					clearTrades()
				end
			elseif row == 3 then

				if col == 1 then
					addContango(-1)
				end
			end
		end

		if msg == QTABLE_RBUTTONDOWN then
			if row == 1 then

				if col == 1 then
					addContango(10)
				end

			elseif row == 3 then

				if col == 1 then
					addContango(-10)
				end
			end
		end
	end


	function metricsCallback(t_id, msg, row, col)											-- �������, ������� ������������ ������� � ���������
		local str = string.format("�������, %s, row = %d, col = %d", event_table[msg], row, col)
		message(str)
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


	function OnAllTrade( trade )															-- ��������� ������������ ������
		if     trade.class_code == futures.class and trade.sec_code == futures.sec then
			local row	= middle + math.floor(rowsCount/2) - trade.price
			addTrade(trade,row,1)
		elseif trade.class_code == share.class   and trade.sec_code == share.sec then
			local row	= middle + math.floor(rowsCount/2 - trade.price * 100) - contango
			addTrade(trade,row,5)
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
					Highlight(metricsId, row, col, RGB(116, 41, 41), QTABLE_DEFAULT_COLOR , 200) 					-- �������
				else
					Highlight(metricsId, row, col, RGB(35, 74, 25), QTABLE_DEFAULT_COLOR , 200)
				end
		end
	end



	function printQuotes()
		quotes 			= getQuoteLevel2 ( futures.class , futures.sec)

		endValue		= middle + math.floor(rowsCount/2)

		

		for i = 1, rowsCount do 								-- ������� ������� � ����� � ������� ���
			SetCell(metricsId, i, 3, tostring( endValue - i) )
			SetCell(metricsId, i, 2, '' )
			SetCell(metricsId, i, 4, '' )

			SetColor(metricsId, i, 2, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
			SetColor(metricsId, i, 3, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
			SetColor(metricsId, i, 4, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
		end

		for k, v in pairs(quotes.bid) do
			local index	= endValue - v.price
			if index <= rowsCount then
				SetCell(metricsId, 	index, 2, tostring( v.quantity) )
				SetColor(metricsId, index, 2, RGB(35, 74, 25), QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
				SetColor(metricsId, index, 3, RGB(35, 74, 25), QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
			end
		end

		for k, v in pairs(quotes.offer) do
			index	= endValue - v.price
			if index >= 1 then
				SetCell(metricsId, 	index, 4, tostring( v.quantity) )
				SetColor(metricsId, index, 4, RGB(116, 41, 41), QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
				SetColor(metricsId, index, 3, RGB(116, 41, 41), QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
			end
		end
	end


	function printQuotes2()
		quotes 			= getQuoteLevel2 ( share.class , share.sec)
		endValue		= middle + math.floor(rowsCount/2) - contango

		

		for i = 1, rowsCount do 								-- ������� ������� � ����� � ������� ���
			SetCell(metricsId, i, 7, string.format("%01.2f", (endValue - i)/100 ) )
			SetCell(metricsId, i, 6, '' )
			SetCell(metricsId, i, 8, '' )

			SetColor(metricsId, i, 6, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
			SetColor(metricsId, i, 7, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
			SetColor(metricsId, i, 8, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
		end


		if tonumber(quotes.bid_count) > 0 then
			for k, v in pairs(quotes.bid) do
				local index	= endValue - math.floor(v.price * 100)
				if index <= rowsCount then
					SetCell(metricsId, 	index, 6, tostring( v.quantity) )
					SetColor(metricsId, index, 6, RGB(35, 74, 25), QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
					SetColor(metricsId, index, 7, RGB(35, 74, 25), QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
				end
			end
		end

		if tonumber(quotes.offer_count) > 0 then
			for k, v in pairs(quotes.offer) do
				index	= endValue - math.floor(v.price * 100)
				if index >= 1 then
					SetCell(metricsId, 	index, 8, tostring( v.quantity) )
					SetColor(metricsId, index, 8, RGB(116, 41, 41), QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
					SetColor(metricsId, index, 7, RGB(116, 41, 41), QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
				end
			end
		end
	end



	function main()
		controlId = AllocTable()															-- ������� ������� � ���������� ����������
		AddColumn(controlId, 1, "��������", true, QTABLE_CACHED_STRING_TYPE, 10)
		AddColumn(controlId, 2, "�����",  true, QTABLE_CACHED_STRING_TYPE, 10)
		AddColumn(controlId, 3, "��������",   true, QTABLE_CACHED_STRING_TYPE, 10)
		CreateWindow(controlId)


		data = {
			{"+ (++ ���)", "1", "������������"},
			{"0", "1", "�������� ������"},
			{"- (-- ���)", "1", "1"}
		}

		for k, v in pairs(data) do
			row = InsertRow(controlId, -1)
			SetCell(controlId, row, 1, v[1])
			SetCell(controlId, row, 2, v[2])
			SetCell(controlId, row, 3, v[3])
		end

		SetWindowCaption(controlId, "����������")
		SetTableNotificationCallback(controlId, controlCallback)



		metricsId = AllocTable()															-- ������� ������� � ��������
		AddColumn(metricsId, 1, "������",	true, QTABLE_INT_TYPE, 10)
		AddColumn(metricsId, 2, "", 		true, QTABLE_INT_TYPE, 10)
		AddColumn(metricsId, 3, "�������",  true, QTABLE_INT_TYPE, 10)
		AddColumn(metricsId, 4, "", 		true, QTABLE_INT_TYPE, 10)
		AddColumn(metricsId, 5, "������",  	true, QTABLE_INT_TYPE, 10)
		AddColumn(metricsId, 6, "", 		true, QTABLE_INT_TYPE, 10)
		AddColumn(metricsId, 7, "�����",  	true, QTABLE_INT_TYPE, 10)
		AddColumn(metricsId, 8, "", 		true, QTABLE_INT_TYPE, 10)
		CreateWindow(metricsId)


		for i = 1, rowsCount do
			row = InsertRow(metricsId, -1)
		end

		SetWindowCaption(metricsId, "�������")
		SetTableNotificationCallback(metricsId, metricsCallback)

		setMiddle()								-- ��������� �������
		printQuotes()
		
		while isRun do
			sleep(500)		-- ��� �� ��������� ���� 100 ��. ���� �� ������������ ��������, �� ������ ���� �������. �� ����� �����
		end
	end