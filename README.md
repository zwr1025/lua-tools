# lua-tools
**exsample:**
```lua
devt=require("devt")
dv=devt.new()
dv:setName("test",{
  on=function(v)
    print ("test="..v)
  end
})
dv:loadStr("test->1")
dv:loadStr("test->2")
```
**output:**
```
test=1
test=2
```
