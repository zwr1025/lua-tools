local devt={}
local tryev=function(self,name,evname,...)
    if self.config.names[name][evname] then
        self.config.names[name][evname](...)
        return false
    end
    return true
end
local trydev =function (self,evname,...)
    if self.events[evname] then
        self.events[evname](...)
        return false
    else
        return true
    end
end
devt.get=function (self,name)
    if self.names[name] then
        return self.names[name].data
    end
    return false
end
devt.new=function (conf)
    local obj={
        ["_err"]=devt._err,
        ["setName"]=devt.setName,
        ["setEvent"]=devt.setEvent,
        ["setErr"]=devt.setErr,
        ["loadStr"]=devt.loadStr,
        ["load"]=devt.load,
        ["get"]=devt.get,
    }
    conf=conf or {}
    obj.config={}
    obj.config.allowCreateName=conf.allowCreateName or false
    obj.config.enableKeywords=conf.enableKeywords or false
    obj.config.onWhenInit=conf.onWhenInit and true
    obj.config.names=obj.config.names or {}
    obj.events={}
    obj.names={}
    obj.errors={}
    obj.keywords={}
    return obj
end
devt.setName=function(self,name,conf)
    self.config.names[name]=conf or {}
end
devt.setErr=function(self,ername,func)
    self.errors[ername]=func
end
devt._err=function(self,errname,...)
    if self.errors[errname] then
        self.errors[errname](...)
        return false
    end
    return true
end
devt.setEvent=function (self,name,evname,func)
    if name=="created" then
        self.events["created"]=evname
        return false
    end
    if self.config.names[name] then
        self.config.names[name][evname]=func
        return false
    end
    return true
end
devt.load=function (self,filename)
    for s in io.lines(filename) do
        self:loadStr(s)
    end
end
devt.loadStr=function(self,str)
    local _start,_end=str:find("->")
    local _name=str:sub(0,_start-1)
    local _value=str:sub(_end+1,#str)
    if self.config.names[_name] then
        if not self.names[_name] then
            self.names[_name]={}
            if self.config.onWhenInit then
                tryev(self,_name,"init",_value)
                tryev(self,_name,"on",_value)
            else
                if tryev(self,_name,"init",_value) then
                    tryev(self,_name,"on",_value)
                end
            end
        else
            tryev(self,_name,"on",_value)
        end
        self.names[_name].data=_value
    else
        if self.config.allowCreateName then
            trydev(self,"created",_name,_value)
        else
            self:_err("undefine",_name,_value)
        end
    end
end
return devt
