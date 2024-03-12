#reloadable
import crafttweaker.data.IData;
import scripts.libs.advanced.Misc as M;
import scripts.libs.basic.Data as D;
import scripts.Config;
events.onWorldTick(function(event as crafttweaker.event.WorldTickEvent){
    var w = event.world;
    if(w.isRemote())return;
    var d = w.getCustomWorldData();
    var t = d.deepGet("modpack.difficulty");
    print(d);
    if(isNull(t)){
        w.updateCustomWorldData(
            d.deepSet(Config.DIFF as int,"modpack.difficulty")
            .deepSet(false as bool,"modpack.survival")
        );
    }
    else{
        print(t.asInt());
        var s = d.deepGet("modpack.survival").asBool();
        if(t.asInt()!=scripts.Config.DIFF && s){
            print(game.localize("modpack.general.difficulty.world_error"));
            M.shout(game.localize("modpack.general.difficulty.world_error"));
        }
    }
});
//TODO: survival map initialization
//TODO: Commands