tradingAccount	= "A709HZP"
clientCode		= "4LUCY/"



function buyMarket(class, sec, count)
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
		["����"]				= '0',
		["����������"]			= tostring(count),
		["������� ����������"]	= "��������� � �������",
		["�����������"]			= clientCode,
		["���������� ������"]	= "���",
		["���� ����������"]		= os.date("%Y%m%d")
	}


	result	= sendTransaction(transaction)

	if result ~= "" then
		message("���� ����������: "..result)
	end
end


function sellMarket(class, sec, count)
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
		["����"]				= '0',
		["����������"]			= tostring(count),
		["������� ����������"]	= "��������� � �������",
		["�����������"]			= clientCode,
		["���������� ������"]	= "���",
		["���� ����������"]		= os.date("%Y%m%d")
	}

	result	= sendTransaction(transaction)

	if result ~= "" then
		message("���� ����������: "..result)
	end
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