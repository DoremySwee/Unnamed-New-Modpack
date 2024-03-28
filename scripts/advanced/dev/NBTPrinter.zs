#reloadable
import mods.zenutils.command.ZenCommand;
import mods.zenutils.command.CommandUtils;
import scripts.libs.basic.Vector3D as V;
import scripts.libs.advanced.Misc as M;

// command printing data of neighboring entities
val printData as ZenCommand = ZenCommand.create("printData");
printData.execute = function(command, server, sender, args) {
    var player = CommandUtils.getCommandSenderAsPlayer(sender);
    var w = player.world;
    var r = (args.length>0) ? (args[0] as int) : 3.0;
    
    var count = 0;
    for entity in w.getEntities(){
        var dpos = V.subtract(V.getPos(entity),V.getPos(player));
        if(V.dot(dpos,dpos)>r*r)continue;
        if(isNull(entity.definition))print("Null Definition");
        else print(entity.definition.name);
        print(entity.nbt);
        count+=1;
    }
    M.shout(""~count~" entities have been founded, and their nbt has been printed");
};
printData.register();