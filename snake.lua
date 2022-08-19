term.redirect(peripheral.wrap("top"))
term.clear()
term.setCursorBlink(false)

local sizex, sizey = term.getSize()
local x, y, vx, vy = math.floor(sizex/2), math.floor(sizey/2), 1, 0
local rot, length = 1, 3

local rotDir = {{1,0}, {0,1}, {-1,0}, {0,-1}}
local snakeBody = {}

local cookiePos = {math.random(sizex),math.random(sizey)}

local lastBtnL = false
local lastBtnR = false

local playing = false

local afkTicks = 0

function drawGameOver()
  term.clear()
  term.setTextColor(1)
  term.setCursorPos(sizex/2-5, sizey/2)
  term.write("Game Over")
  term.setCursorPos(sizex/2-5, sizey/2+1)
  term.write("Score: ")
  term.write(tostring(length*100))
end

function handleGameRestart()
  x, y, vx, vy = math.floor(sizex/2), math.floor(sizey/2), 1, 0
  rot, length = 1, 3
  cookiePos = {math.random(sizex),math.random(sizey)}
  snakeBody = {}
  playing = true
end

while true do
  os.sleep(0.2)
  local btnL = redstone.getInput("left")
  local btnR = redstone.getInput("right")
  if (btnL ~= lastBtnL) then
    if rot == 1 then
      rot = 4
    else
      rot = rot - 1
    end
    afkTicks = 0
    if playing == false then handleGameRestart() end
  end
  if (btnR ~= lastBtnR) then
    if rot == 4 then
      rot = 1
    else
      rot = rot + 1
    end
    afkTicks = 0
    if playing == false then handleGameRestart() end
  end
  lastBtnL = btnL
  lastBtnR = btnR
  afkTicks = afkTicks + 1
  if afkTicks > 500 then
    playing = false
  end
  if playing == false then
    drawGameOver()
  else
    vx = rotDir[rot][1]
    vy = rotDir[rot][2]
    x = x + vx
    y = y + vy
    if (x > sizex) then x = 1 end
    if (y > sizey) then y = 1 end
    if (x < 1) then x = sizex end
    if (y < 1) then y = sizey end
    term.clear()
    term.setTextColor(1)
    term.setCursorPos(x,y)
    term.write("o")
    local bodyPartsRendered = table.getn(snakeBody)
    for i=1,bodyPartsRendered do
      local bodyPos = snakeBody[i]
      term.setTextColor(2^((i+1)%14))
      term.setCursorPos(bodyPos[1], bodyPos[2])
      term.write("o")
      if (x == bodyPos[1] and y == bodyPos[2]) then
        playing = false
        drawGameOver()
        os.sleep(3)
      end
    end
    if (x == cookiePos[1] and y == cookiePos[2]) then
      cookiePos = {math.random(sizex),math.random(sizey)}
      length = length + 1
    end
    local cookieCol = math.random(14)
    term.setTextColor(2^cookieCol)
    term.setCursorPos(cookiePos[1], cookiePos[2])
    term.write("*")
    for i=length-1,1,-1 do
      if i == 1 then
        snakeBody[i] = {x,y}
      else
        snakeBody[i] = snakeBody[i-1]
      end
    end
  end
end
