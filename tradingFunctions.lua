tradingAccount	= "SPBFUT002T9"
clientCode		= "SPBFUT002T9/"



function buyMarket(class, sec, count)
	local quotes	= getQuoteLevel2 ( class , sec)
	local result 	= ""

	local transaction = {
		TRANS_ID				= "104",
		CLASSCODE				= class,
		ACTION					= "���� ������",
		["�������� ����"]		= tradingAccount,
		["�/�"] 				= "�������",
		["���"]					= "��������",
		["�����"]				= class,
		["����������"]			= sec,
		["����"]				= '',
		["����������"]			= tostring(count),
		["������� ����������"]	= "��������� � �������",
		["�����������"]			= clientCode,
		["���������� ������"]	= "���",
		["���� ����������"]		= os.date("%Y%m%d")
	}

	for i = 1, tonumber(quotes.offer_count) do
		transaction['����']	= tostring(quotes.offer[i].price)

		if tonumber(quotes.offer[i].quantity) >= count then
			transaction['����������']	= tostring(count)
			result	= sendTransaction(transaction)
			break
		else
			transaction['����������']	= tostring(quotes.offer[i].quantity)
			result	= sendTransaction(transaction)
			count 	= count - quotes.offer[i].quantity
		end

		if result ~= "" then
			message("���� ����������: "..result)
		end
	end

	return tonumber(transaction['����'])
end


function sellMarket(class, sec, count)
	local quotes	= getQuoteLevel2 ( class , sec)
	local result 	= ""

	local transaction = {
		TRANS_ID				= "105",
		CLASSCODE				= class,
		ACTION					= "���� ������",
		["�������� ����"]		= tradingAccount,
		["�/�"] 				= "�������",
		["���"]					= "��������",
		["�����"]				= class,
		["����������"]			= sec,
		["����"]				= '',
		["����������"]			= tostring(count),
		["������� ����������"]	= "��������� � �������",
		["�����������"]			= clientCode,
		["���������� ������"]	= "���",
		["���� ����������"]		= os.date("%Y%m%d")
	}


	for i = tonumber(quotes.bid_count),1, -1 do
		transaction['����']	= tostring(quotes.bid[i].price)

		if tonumber(quotes.bid[i].quantity) >= count then
			transaction['����������']	= tostring(count)
			result	= sendTransaction(transaction)
			break
		else
			transaction['����������']	= tostring(quotes.bid[i].quantity)
			result	= sendTransaction(transaction)
			count 	= count - quotes.bid[i].quantity
		end

		if result ~= "" then
			message("���� ����������: "..result)
		end
	end

	return tonumber(transaction['����'])
end



function buyLimit(class, sec, count, price)
	local transaction = {
		TRANS_ID				= "104",
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
	local transaction = {
		TRANS_ID				= "105",
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


function dropLimit(class,assets)
	local transaction = {
		TRANS_ID				= "104",
		CLASSCODE				= class,
		ACTION					= "������� ��� ������ �� �������",
		["�������� ����"]		= tradingAccount,
		["��������������"] 		= "���",
		["��� ������"]			= "���",
		["������� �����"]		= assets
	}

	return sendTransaction(transaction)
end


function buyStop(class, sec, count, price, stopPrice)
	transaction = {
		TRANS_ID				= "108",
		CLASSCODE				= class,
		ACTION					= "����-������",
		["��� ����-������"] 	= "����-�����",
		["��������� ��"] 		= "-1",
		["�������� ����"]		= tradingAccount,
		["�/�"] 				= "�����",
		["�������"] 			= ">=",
		["����-����"] 			= tostring(stopPrice),
		["�����"] 				= "2",
		["�����"] 				= class,
		["����������"] 			= sec,
		["������ ������"] 		= sec,
		["����� ������"]		= class,
		["����"]				= tostring(price),
		["����������"]			= tostring(count),
		["����������"]			= clientCode,
		["���� ���. ������"]	= "0",
		["������"]				= "0,000000",
		["���. �����"]			= "0,000000",
		["����� ���. ������"]	= "0",
		["������� �"]			= "0",
		["������� ��"]			= "235959",
		["����-����2"]			= "0",
	}

	return sendTransaction(transaction)
end


function sellStop(class, sec, count, price, stopPrice)
	transaction = {
		TRANS_ID				= "108",
		CLASSCODE				= class,
		ACTION					= "����-������",
		["��� ����-������"] 	= "����-�����",
		["��������� ��"] 		= "-1",
		["�������� ����"]		= tradingAccount,
		["�/�"] 				= "�������",
		["�������"] 			= "<=",
		["����-����"] 			= tostring(stopPrice),
		["�����"] 				= "2",
		["�����"] 				= class,
		["����������"] 			= sec,
		["������ ������"] 		= sec,
		["����� ������"]		= class,
		["����"]				= tostring(price),
		["����������"]			= tostring(count),
		["����������"]			= clientCode,
		["���� ���. ������"]	= "0",
		["������"]				= "0,000000",
		["���. �����"]			= "0,000000",
		["����� ���. ������"]	= "0",
		["������� �"]			= "0",
		["������� ��"]			= "235959",
		["����-����2"]			= "0",
	}

	return sendTransaction(transaction)
end

function dropStop(class, id )
	transaction = {
		TRANS_ID				= "101",
		CLASSCODE				= class,
		ACTION					= "����� ����-������",
		["����� ����-������"] 	= tostring(id),
	}

	return sendTransaction(transaction)
end