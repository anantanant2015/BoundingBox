defmodule BoundPairs do
   def start(pairs_path \\ "/home/anant/Downloads/pairs.csv", cords_path \\ "/home/anant/Downloads/coordinates.csv") do
     {_, pairs_data} = readFile(pairs_path)
     {_, cords_data} = readFile(cords_path)

     pairs = if pairs_data do
     	pairs_data
     	|> fileToCordsList()
     	else
     	[]
     end

     pairs_data = ''

     cords = if cords_data do
     	cords_data
     	|> fileToCordsList()
     end

     cords_data = ''
     pairs_list = pairs |> getPairs()
     pairs = ''

   end

   def readFile(file_path) do
   	File.read(file_path)
   end

   def stringTrimLeading(any_string, trim_leading \\ "lon,lat\n") do
   	String.trim_leading(any_string, trim_leading)
   end

   def stringSplitter(any_string, pattern_list) do
   	String.splitter(any_string, pattern_list)
   end

   def toList(list) do
   	Enum.into(list, [], fn x -> x end)
   end

   def filterEmpty(list) do
   	list
   	|> Enum.filter(fn x -> x != "" end)
   end

   def stringToFloatTupleList(str) do
   	 str
   	 |> String.split(",")
     |> Enum.into([], fn x -> x |> String.to_float end) 
     |> List.to_tuple
   end

   def listToTupleElementList(list) do
   	list
   	|> Enum.into([], fn x -> if x != "" do x |> BoundPairs.stringToFloatTupleList end end)
   end

   def fileToCordsList(filedata) do
   	filedata
     |> stringTrimLeading()
     |> stringSplitter(["\n"])
     |> toList()
     |> filterEmpty()
     |> listToTupleElementList()
   end

   def returnListHead(list) do
    if Enum.count(list) >= 2 do
    	[head | tail] = list
    	head
    else
    	nil
    end
   end

   def formPairs(list) do
   	list
   	|> Enum.map(fn x -> BoundPairs.makePairs(x, list, []) end) |> Enum.reduce(fn y, acc -> y ++ acc end)
   end

   def getPairs(list) do
   	list
   	|> Enum.map(fn x -> BoundPairs.makePairs(x, list, []) end)
   	|> Enum.reduce(fn x, acc -> x ++ acc end)
	end

   def makePairs(first, [head | tail], accumulator) do
    makePairs(first, tail, 
    	if first != head do
    		[[first, head]] ++ accumulator 
    		else
    		[] ++ accumulator
    	end)
  end

  def makePairs(first, [], accumulator) do
    accumulator
  end

  def evalCord(pairs_tuple_list, {x, y}) do
  		{x1, y1} = pairs_tuple_list |> List.first()
  		{x2, y2} = pairs_tuple_list |> List.last()

  		if evalX(x1, x2, x) && evalY(y1, y2, y) do
  			true
  		else
  			false
  		end

	end

	def evalX(x1, x2, x) do
		(x1 == x2 == x) || (x <= x1) && (x >= x2) || (x <= x2) && (x >= x1)
	end

	def evalY(y1, y2, y) do
		(y1 == y2 == y) || (y <= y1) && (y >= y2) || (y <= y2) && (y >= y1)
	end

	def getBbxPairOfCord(pairs_list, cord) do
		pairs_list
		|> Enum.reduce(fn x, acc -> if BoundPairs.evalCord(x, cord) do [x] ++ acc else [[{}]] end end)
		|> Enum.filter(fn x -> x != [{}] end)
	end

	def getBbxPairOfCords(pairs_list, origin_cord, destination_cord) do
		getBbxPairOfCord(pairs_list, origin_cord)
		|> Enum.concat(getBbxPairOfCord(pairs_list, destination_cord))
	end
end

