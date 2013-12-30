#Game Design - Treasure Hunter - by Bjorn Linder
#A grid-based game of searching for hidden artifacts.

#Global variables. I've read that we should avoid using them when possible, but they're just so nice...
$grid=Hash.new(0) #The grid, aka gameboard
$d=3              #Number of levels down items are generated.
$location=[0,0,0] #Current location
$output=[]        #Output generated when user digs for items
$dimensions=[]    #Size of map as entered by user
#The grid is set up as a hash so that data is only stored for those tiles that have an item or have been dug out.

puts "Welcome to Treasure Hunter! Before we begin, I must warn you that this game has no purpose. \
There is no way to win or lose. In fact, I'm hoping to inspire existential angst and despair \
when you see that in the long run, nothing you do really matters. Well, have fun playing!"

#I want to return a different distribution of items at each level of the map.
#Ideally this section would not require three global variables and repeat code.
$items1=[0,0,0,0,0,1,1,2,5,5]
$items2=[0,0,0,0,0,0,0,1,2,4]
$items3=[0,0,0,0,0,0,2,3,3,4]
def populate level
  if level==0
    return $items1[rand(10)]
  elsif level==1
    return $items2[rand(10)]
  elsif level==2
    return $items3[rand(10)]
  end
end

#Treasure generation for the entire map is done here in the map initialization.
#The game could also be coded to roll for treasure every time the user digs for it.
def generate
  for i in 0..$dimensions[0]-1
    for j in 0..$dimensions[1]-1
      for k in 0..$d-1
        item=populate k
        if item!=0          
          $grid[[i,j,k]]=item
        end
      end
    end
  end
end

#how would I best avoid initializing the artifact arrays & strings each time this method is called?
#All I can think of right now is using more global variables.
def artifact type 
  cheeses=["Camembert","Parmesan","Cheddar","Wisconsin","Brie","Stinky","Blue","Gorgonzola","Goat","Gouda"]
  bones=["human","neanderthal","sasquatch","velociraptor","human child","buffalo","alien"]
  civs=["Mayan","Greek","Chinese","Collector's Edition","Persian","Roman"]
  animals=["Aaron the Aardvark","Wile E. Coyote","killer rabbit","Chupacabra","Tobbits the Hobbit","Pikachu","Ling-Ling"]
  if type=="cheese"
    return cheeses[rand(10)]
  elsif type=="bones"
    return bones[rand(7)]
  elsif type=="coin"
    return civs[rand(6)]
  elsif type=="animal"
    return animals[rand(7)]
  end
end

#For a proper program we would want to move the items and output to an external file.
$output[0]=("You find nothing.")
$output[1]=("You found some crap. No really, it seems a dog conducted some business and cleaned up after itself.")

def output item
  if item==2
    cheese=artifact "cheese"
    $output[2]="You find a hunk of #{cheese} cheese. It's still wrapped up and hasn't expired yet either. Weird."
  elsif item==3
    coin=artifact "coin"
    $output[3]="You find some ancient #{coin} gold coins. Congratulations."
  elsif item==4
    bones=artifact "bones"
    $output[4]="You find some bones. As you continue digging, you find the remainder of a #{bones} skeleton."
  elsif item==5
    animal=artifact "animal"
    $output[5]="You have disturbed the #{animal} resting in its burrow. The angry #{animal} attacks and you barely escape with your life"
  end
  return $output[item]
end

def intro
  puts "How large would you like the gameboard to be?
  Please enter the desired board dimensions in the format 'x.y' (for example, '5.7')."
  $dimensions=gets.chomp.split(".").map{|s| s.to_i}
  unless ($dimensions[0]>0&&$dimensions[1]>0)
    puts "It's really not supposed to be that hard. Try again."
    intro
  end
  generate
end
intro

def move dir
  $location[2]=0
  if dir=="n"
    $location[0]=$location[0].+1
  elsif dir=="s"
    $location[0]=$location[0].-1
  elsif dir=="e"
    $location[1]=$location[1].+1
  elsif dir=="w"
    $location[1]=$location[1].-1
  else
    puts "DOES NOT COMPUTE. REPORT CODE 00000000001011101111 TO ADMINISTRATOR."
    return false
  end
  if $location[0]>$dimensions[0]||$location[0]<0||$location[1]<0||$location[1]>$dimensions[1]
    abort dir
    return false
  else
    return true
  end
end

def abort dir
  reverse={"e"=>"w","w"=>"e","n"=>"s","s"=>"n"}
  puts "You have reached the edge of the world. You barely catch youself before falling off."
  move reverse[dir]
end
    
def search
  item=$grid[$location]
  if $location[2]>2
    puts "You find hard rock and can't dig any deeper. Try 'move'."
    return
  elsif item=="dug"
    $location[2]=$location[2]+1
   #For troubleshooting: puts "grid: #{$grid}; location: #{$location} and grid location:       #{$grid[$location]}"
    search
  else
    puts output item    
    $grid[$location]="dug"  #I suspect this line is where the trouble is. It seems to change more keys in the hash than its supposed to.
  end
end

puts "Type 'dig' to search for buried treasure, 'move (n/s/e/w)' to move in the given direction, or 'done' to exit the game."
while true
  input=gets.chomp.downcase
  if input=="done"
    puts "Have a nice day!"
    exit
  elsif input.include? "dig"
    search
    puts "Would you like to dig or move?"
  elsif ((input.include? "move") && (input[-2,2]!="ve"))
    dir=input[-1,1]
    if move dir
      puts "You move one tile #{dir}. Care for some wine?"
    end
  else
    puts "Please type 'dig', 'move (n/s/e/w)', or 'done'."
  end
end