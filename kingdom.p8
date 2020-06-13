pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function _init()
  game = {}
  run_level()
end

function _update() game.update() end

function _draw() game.draw() end

function run_level()
  foobar = false
  ground_y = 128 - 32
  camera_x = 0
  map_start_x = 0
  map_end_x = 256
  coin_score = 10
  coins = {}
  buy_time = 1
  buyable_items = {}
  button_pressed = false
  button_pressed_counter = 0
  level = 0
  civilians = {}
  counter = 0
  town_center = 64 + 4
  town_left_border = town_center - 48
  town_right_border = town_center + 48
  hunters = {}

  
  player = {
   sprite = 0,
   x = 130,
   y = ground_y - 8,
   width = 8,
   height = 8,
   center_x = function(self)
    return self.x + self.width/2
   end
  }

  burrow = {
   sprite = 11,
   x = 146,
   y = ground_y - 8,
   width = 8,
   height = 8
  }

  rabbit = {
   sprite = 12,
   x = 154,
   y = ground_y - 8,
   width = 6,
   height = 5
  }

  camp_fire = {
   sprite = 6,
   bought_action = function(self)
    self.sprite = 7
    self.is_bought = true
   end,
   x = town_center - 4,
   y = ground_y - 8,
   width = 8,
   height = 8,
   is_bought = false,
   cost = {
    value = 2,
    spent = 0,
    buy_time = 0
   },
   draw_self = function(self)
    spr(self.sprite,self.x,self.y)
   end
  }

  civilian = {
   sprite = 10,
   bought_action = function(self)
    self.sprite = 9
    add(civilians,self)
    del(buyable_items,self)
   end,
   x = 150,
   y = ground_y - 8,
   width = 8,
   height = 8,
   is_bought = false,
   cost = {
    value = 1,
    spent = 0,
    buy_time = 0
   },
   draw_self = function(self)
    spr(self.sprite,self.x,self.y)
   end,
   rnd_move = false,
   destination = camp_fire,
   choose_destination = function(self)
    if within_town(self.x) then
     if archery_shop.products > 0 then
      self.destination = archery_shop
     else
      self:choose_rand_dest_in_town()
     end
    else
     self.destination = camp_fire
    end
   end,
   choose_rand_dest_in_town = function(self)
    if is_overlapping(self, self.destination) then self.rnd_move = false end
    if self.rnd_move == false then
     self.destination = {
      x = town_left_border + flr(rnd(town_right_border - town_left_border)),
      width = 8
      }
     self.rnd_move = true
    end
   end,
   update = function(self)
    if is_overlapping(self, archery_shop) and archery_shop.products > 0 then
     archery_shop.products -= 1
     add(hunters,make_hunter(self.x, self.y))
     del(civilians,self)
    end
    self:choose_destination()
    local speed = (self.x - self.destination.x > 0) and -1 or 1
    if self.destination == archery_shop then
     self.x += speed
    else
     if counter % 3 == 0 then self.x += speed end 
    end
   end
  }

  archery_shop = {
   sprite = 16,
   sprite_width = 1,
   sprite_height = 2,
   bought_action = function(self)
    self.products += 1
    self.cost.spent = 0
   end,
   x = 96,
   y = ground_y - 16,
   width = 16,
   height = 16,
   is_bought = false,
   cost = {
    value = 2,
    spent = 0,
    buy_time = 0
   },
   products = 0,
   draw_products = function(self)
    local start_x = self.x + self.width
    for a=1,self.products do
     line(start_x,self.y,start_x,self.y + 8,7)
     start_x += 2
    end
   end,
   draw_self = function(self)
    spr(self.sprite,self.x,ground_y - self.height,self.sprite_width,self.sprite_height)
    spr(self.sprite,self.x + (self.sprite_width * 8),ground_y - self.height,self.sprite_width,self.sprite_height, true, false)
   end
  }

  add(buyable_items,camp_fire)

  cam = {
   x = 0,
   width = 128
  } 

  game.update = level_update
  game.draw = level_draw
end

function level_update()
 counter += 1
 --player
 if btn(0) then player.x -= 1 end
 if btn(1) then player.x += 1 end
 if btn(2) then player.y -= 1 end
 if btn(3) then player.y += 1 end
 manage_out_of_bounds(player)
 --camera
 cam.x = player.x - 64 + (player.width/2)
 manage_out_of_bounds(cam)
 camera(cam.x,0)
 --collect coins
 for c in all(coins) do
  if player:center_x() > c.x and player:center_x() < (c.x + c.width) then 
   del(coins,c)
   coin_score +=1
  end 
 end
 --buy button
 if btn(5) then
  button_pressed = true
  for b in all(buyable_items) do
   check_overlap_and_buy_item(b)
  end
 else
  button_pressed = false
  for b in all(buyable_items) do
   check_overlap_and_reset_item_cost(b)
  end
 end
 --update civilians
 for civ in all(civilians) do
  civ:update()
 end

 manage_button_pressed_counter()
 manage_level_changes()
end



function level_draw()
 cls()
 map(0,0)
 print('coins_score:'..coin_score, 10, 10, 7)
 spr(player.sprite,player.x,player.y)
 for item in all(buyable_items) do
  item:draw_self()
  if is_overlapping(player,item) and not item.is_bought then
   draw_cost(item)
  end
  if item.products then
   item:draw_products()
  end
 end
 if is_overlapping(player, camp_fire) and not camp_fire.is_bought then
  print('hold x to light fire',64 - 40,30,7)
 end

 for c in all(coins) do
  spr(c.sprite,c.x,c.y)
 end

 for civ in all(civilians) do
  spr(civ.sprite,civ.x,civ.y)
 end

 for hunter in all(hunters) do
  spr(hunter.sprite,hunter.x,hunter.y)
 end

 spr(burrow.sprite,burrow.x,burrow.y)
 spr(rabbit.sprite,rabbit.x,rabbit.y)

end

function make_hunter(x,y)
 local hunter = {
  sprite = 4,
  x = x,
  y = y,
  width = 8,
  height = 8
 }
 return hunter
end

function within_town(x)
 return x > town_left_border and x < town_right_border
end

function manage_level_changes()
 if camp_fire.is_bought and level == 0 then
  level = 1
 -- if btnp(4) then
  add(buyable_items,archery_shop)
  add(buyable_items,civilian)
 end
end

function manage_button_pressed_counter()
 if button_pressed then
  button_pressed_counter += 1
 else
  button_pressed_counter = 0
 end
end

function reset_cost(item)
 item.cost.spent = 0
 item.cost.buy_time = 0
end

function check_overlap_and_reset_item_cost(item)
 if is_overlapping(player, item) and not item.is_bought then
  coin_score += item.cost.spent
  reset_cost(item)
 end
end

function check_overlap_and_buy_item(item)
 if is_overlapping(player, item) and (button_pressed_counter % 10 == 0) then
  if item.cost.spent < item.cost.value then
   if coin_score > 0 then
    coin_score -= 1
    item.cost.spent += 1
   end
  else
   item.cost.buy_time += 1/2
   if item.cost.buy_time >= buy_time then
    item:bought_action()
   end
  end
 end
end

function draw_cost(item)
 local adjust = 0
 local spent = item.cost.spent
 local remaining = item.cost.value - item.cost.spent
 for n=0,spent - 1 do
  spr(5,item.x + adjust,item.y - 16)
  adjust+=8
 end
 for n=0,remaining - 1 do
  spr(8,item.x + adjust,item.y - 16)
  adjust+=8
 end
end

function manage_out_of_bounds(obj)
 if obj.x < map_start_x then obj.x = map_start_x end
 if obj.x + obj.width > map_end_x then obj.x = (map_end_x - obj.width) end 
end

function is_overlapping(obj_one, obj_two)
 local left1 = obj_one.x
 local right1 = obj_one.x + obj_one.width
 local left2 = obj_two.x
 local right2 = obj_two.x + obj_two.width
 if right1>left2 and right2>left1 then
  return true
 else
  return false
 end 
end

function make_coin(x,y)
 local coin = {
  sprite = 5,
  x = x,
  y = y,
  width = 8,
  height = 8
 }
 return coin
end

function make_arrow(x,y)
 local arrow = {
  x = x,
  y = y,
  col = 14
 }
 return arrow
end

__gfx__
1a1a919133333333cccccccc000101000713310000444400000000000000000000dddd0000000000000000000030000000000000000000000000000000000000
1aaa999133333333cccccccc00161610017333100477fa2000000000000000000d1111d000000000000000000030000300000000000000000000000000000000
1999999133333333cccccccc001616101333333147f99af20000000000a00a00d111111d01111110011111100333033000000000000000000000000000000000
1444442133333333cccccccc00161610144444214f9999a24404404400a00a00d111111d14444421100000013333333300606000000000000000000000000000
1441441133333333cccccccc01166161144144114a9999a2440440440a9aa9a0d111111d14414411100100113333333300606000000000000000000000000000
1444442133333333cccccccc16666661144444214fa99a72440440440a9aa9a0d111111d14444421100000013333333301616100000000000000000000000000
1444422133333333cccccccc1666dd101444422104aa772065665665675775760d1111d014444221100000013333333316666100000000000000000000000000
0141121033333333cccccccc161d16100141121000442200555555556656656600dddd0001411210010110100333333016161000000000000000000000000000
01111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
19988889000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
19988889000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
19988889000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
19988889000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
19988889000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18822228000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18822228000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
12222222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
14444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
14444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202010202010202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
