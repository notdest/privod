rowsCount	= 80	-- ��������� ������� � ������������

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
		if class =="SPBFUT" and sec == "SRM0" then
			printQuotes()
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

	function controlCallback(t_id, msg, row, col)											-- �������, ������� ������������ ������� ����������
		if msg == QTABLE_LBUTTONDOWN then
			if row == 1 then

				if col == 1 then
					contango = contango + 1
					SetCell(controlId, 2, 1, tostring(contango) )
					printQuotes2()
				elseif col == 3 then
					setMiddle()
				end

			elseif row == 3 then

				if col == 1 then
					contango = contango - 1
					SetCell(controlId, 2, 1, tostring(contango) )
					printQuotes2()
				end
			end
		end

		if msg == QTABLE_RBUTTONDOWN then
			if row == 1 then

				if col == 1 then
					contango = contango + 10
					SetCell(controlId, 2, 1, tostring(contango) )
					printQuotes2()
				end

			elseif row == 3 then

				if col == 1 then
					contango = contango - 10
					SetCell(controlId, 2, 1, tostring(contango) )
					printQuotes2()
				end
			end
		end
	end


	function metricsCallback(t_id, msg, row, col)											-- �������, ������� ������������ ������� � ���������
		local str = string.format("�������, %s, row = %d, col = %d", event_table[msg], row, col)
		message(str)
	end


	function setMiddle()
		quotes = getQuoteLevel2 ( "SPBFUT" , "SRM0")
		middle = math.ceil(  (quotes.offer[1].price + quotes.bid[ math.floor(quotes.bid_count) ].price )/2  )
	end

	function printQuotes()
		quotes 			= getQuoteLevel2 ( "SPBFUT" , "SRM0")

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
			index	= endValue - v.price
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
		quotes 			= getQuoteLevel2 ( "SPBFUT" , "SRM0")	-- aaaaaaaaaaaaaaaaaaaa
		--quotes 			= getQuoteLevel2 ( "TQBR" , "SBER")	-- aaaaaaaaaaaaaaaaaaaa
		endValue		= middle + math.floor(rowsCount/2) - contango

		

		for i = 1, rowsCount do 								-- ������� ������� � ����� � ������� ���
			SetCell(metricsId, i, 7, tostring( endValue - i) )
			SetCell(metricsId, i, 6, '' )
			SetCell(metricsId, i, 8, '' )

			SetColor(metricsId, i, 6, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
			SetColor(metricsId, i, 7, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
			SetColor(metricsId, i, 8, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
		end

		for k, v in pairs(quotes.bid) do
			index	= endValue - v.price
			if index <= rowsCount then
				SetCell(metricsId, 	index, 6, tostring( v.quantity) )
				SetColor(metricsId, index, 6, RGB(35, 74, 25), QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
				SetColor(metricsId, index, 7, RGB(35, 74, 25), QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
			end
		end

		for k, v in pairs(quotes.offer) do
			index	= endValue - v.price
			if index >= 1 then
				SetCell(metricsId, 	index, 8, tostring( v.quantity) )
				SetColor(metricsId, index, 8, RGB(116, 41, 41), QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
				SetColor(metricsId, index, 7, RGB(116, 41, 41), QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
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
			{"0", "1", "1"},
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