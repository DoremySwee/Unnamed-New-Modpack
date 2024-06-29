#reloadable
#priority -100000111
#norun
import scripts.libs.advanced.UniversalTicker as UT;
import scripts.libs.advanced.Misc as M;

for def, lis in UT.Listeners{
    def.onTick(function(entity){
        var data = null;
        for li in lis{
            if(li.checkData && isNull(data))data=entity.nbt;
            li.tick(entity,data);
        }
    });
}