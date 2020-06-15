tradingAccount	= "SPBFUT009HF"
clientCode		= "SPBFUT00390/"



function buyMarket(class, sec, count)
	local quotes	= getQuoteLevel2 ( class , sec)
	local price 	= tostring( quotes.offer[1].price )

	local transaction = {
		TRANS_ID				= "4",
		CLASSCODE				= class,
		ACTION					= "���� ������",
		["�������� ����"]		= tradingAccount,
		["�/�"] 				= "�������",
		["���"]					= "��������",
		["�����"]				= class,
		["����������"]			= sec,
		["����"]				= price,
		["����������"]			= tostring(count),
		["������� ����������"]	= "��������� � �������",
		["�����������"]			= clientCode,
		["���������� ������"]	= "���",
		["���� ����������"]		= os.date("%Y%m%d")
	}

	return sendTransaction(transaction)
end


function sellMarket(class, sec, count)
	local quotes	= getQuoteLevel2 ( class , sec)
	local price 	= tostring( quotes.bid[ math.floor(quotes.bid_count) ].price )

	local transaction = {
		TRANS_ID				= "5",
		CLASSCODE				= class,
		ACTION					= "���� ������",
		["�������� ����"]		= tradingAccount,
		["�/�"] 				= "�������",
		["���"]					= "��������",
		["�����"]				= class,
		["����������"]			= sec,
		["����"]				= price,
		["����������"]			= tostring(count),
		["������� ����������"]	= "��������� � �������",
		["�����������"]			= clientCode,
		["���������� ������"]	= "���",
		["���� ����������"]		= os.date("%Y%m%d")
	}

	return sendTransaction(transaction)
end



function buyLimit(class, sec, count, price)
	transaction = {
		TRANS_ID				= "4",
		CLASSCODE				= class,
		ACTION					= "���� ������",
		["�������� ����"]		= tradingAccount,
		["�/�"] 				= "�������",
		["���"]					= "��������������",
		["�����"]				= class,
		["����������"]			= sec,
		["����"]				= tostring(price),
		["����������"]			= tostring(count),
		["������� ����������"]	= "��������� � �������",
		["�����������"]			= clientCode,
		["���������� ������"]	= "���",
		["���� ����������"]		= os.date("%Y%m%d")
	}

	return sendTransaction(transaction)
end


function sellLimit(class, sec, count, price)
	transaction = {
		TRANS_ID				= "5",
		CLASSCODE				= class,
		ACTION					= "���� ������",
		["�������� ����"]		= tradingAccount,
		["�/�"] 				= "�������",
		["���"]					= "��������������",
		["�����"]				= class,
		["����������"]			= sec,
		["����"]				= tostring(price),
		["����������"]			= tostring(count),
		["������� ����������"]	= "��������� � �������",
		["�����������"]			= clientCode,
		["���������� ������"]	= "���",
		["���� ����������"]		= os.date("%Y%m%d")
	}

	return sendTransaction(transaction)
end