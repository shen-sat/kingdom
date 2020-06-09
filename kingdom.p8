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
  ground_y = 128 - 32
  camera_x = 0
  map_start_x = 0
  map_end_x = 256
  coin_score = 0
  coins = {}
  purchase_time = 1
  
  player = {
   sprite = 0,
   x = 10,
   y = ground_y - 8,
   width = 8,
   height = 8,
   center_x = function(self)
    return self.x + self.width/2
   end
  }
  local first_coin = make_coin(20, ground_y - 8)
  add(coins,first_coin)

  camp_fire = {
   sprite = 6,
   x = 64,
   y = ground_y - 8,
   width = 8,
   height = 8,
   purchased = false,
   cost = {
    sprite = 8,
    x = 64,
    y = ground_y - 8 - 16,
    value = 1,
    spent = 0,
    purchase_time = 0
   }
  }

  cam = {
   x = 0,
   width = 128
  } 

  game.update = level_update
  game.draw = level_draw
end

function level_update()
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

 for c in all(coins) do
  if player:center_x() > c.x and player:center_x() < (c.x + c.width) then 
   del(coins,c)
   coin_score +=1
  end 
 end

 if is_overlapping(player, camp_fire) and btnp(5) then
  
  if camp_fire.cost.spent < camp_fire.cost.value then
   if coin_score > 0 then
    coin_score -= 1
    camp_fire.cost.spent += 1
    camp_fire.cost.sprite = 5
   end
  elseif not camp_fire.purchased then
   camp_fire.cost.purchase_time += (1/3)
   if camp_fire.cost.purchase_time >= purchase_time then
    camp_fire.purchased = true
    camp_fire.sprite = 7
   end
  end
 end

end



function level_draw()
 cls()
 map(0,0)
 print('coins_score:'..coin_score, 10, 10, 7)
 print(camp_fire.cost.purchase_time, 20, 20, 7)
 for cst in all(cost_icons) do
  spr(cst.sprite,cst.x,cst.y)
 end
 spr(player.sprite,player.x,player.y)
 spr(camp_fire.sprite,camp_fire.x,camp_fire.y)
 if is_overlapping(player, camp_fire) and not camp_fire.purchased then
   spr(camp_fire.cost.sprite,camp_fire.cost.x,camp_fire.cost.y)
 end
 for c in all(coins) do
  spr(c.sprite,c.x,c.y)
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

__gfx__
1a1a919133333333cccccccc000101000713310000444400000000000000000000dddd0000000000000000000000000000000000000000000000000000000000
1aaa999133333333cccccccc00161610017333100477fa2000000000000000000d1111d000000000000000000000000000000000000000000000000000000000
1999999133333333cccccccc001616101333333147f99af20000000000a00a00d111111d00000000000000000000000000000000000000000000000000000000
1444442133333333cccccccc00161610144444214f9999a24404404400a00a00d111111d00000000000000000000000000000000000000000000000000000000
1441441133333333cccccccc01166161144144114a9999a2440440440a9aa9a0d111111d00000000000000000000000000000000000000000000000000000000
1444442133333333cccccccc16666661144444214fa99a72440440440a9aa9a0d111111d00000000000000000000000000000000000000000000000000000000
1444422133333333cccccccc1666dd101444422104aa772065665665675775760d1111d000000000000000000000000000000000000000000000000000000000
0141121033333333cccccccc161d16100141121000442200555555556656656600dddd0000000000000000000000000000000000000000000000000000000000
__map__
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020201020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020101010202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020201020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020201020202020202020202020202010202010202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
