#reloadable
#priority 100000111
#norun
import crafttweaker.data.IData;
import crafttweaker.world.IWorld;
import crafttweaker.entity.IEntity;
import crafttweaker.event.WorldTickEvent;
import crafttweaker.entity.IEntityDefinition;

zenClass Listener{
    var entityType as IEntityDefinition;
    var checkData as bool;
    var tick as function(IEntity, IData)void;
    zenConstructor(a  as IEntityDefinition,b as bool,c as function(IEntity, IData)void){
        entityType=a;
        checkData=b;
        tick=c;
    }
}
static Listeners as [Listener][IEntityDefinition] = {} as [Listener][IEntityDefinition];
function register(def as IEntityDefinition, tick as function(IEntity)void){
    var t = Listener(def, false, 
        function(a as IEntity,c as IData)as void{
            tick(a);
        }
    );
    if(Listeners has def)Listeners[def] = Listeners[def] + t;
    else Listeners[def] = [t] as [Listener];
}
function register2(def as IEntityDefinition, tick as function(IEntity, IData)void){
    var t = Listener(def, true, tick);
    if(Listeners has def)Listeners[def] = Listeners[def] + t;
    else Listeners[def] = [t] as [Listener];
}
/*
events.register(function(event as WorldTickEvent){
    var world as IWorld=event.world;
    if(world.remote)return;
    for i in world.getEntities(){
        if(isNull(i.definition))continue;
        if(Listeners has i.definition){
            var data as IData = null;
            for l in Listeners[i.definition]{
                if(l.checkData && isNull(data)) data = i.getNBT();
                l.tick(i,event,data);
            }
        }
    }
});*/