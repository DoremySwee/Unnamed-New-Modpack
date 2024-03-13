#reloadable
#priority 10000
import crafttweaker.data.IData;
import scripts.libs.advanced.Misc as M;
import scripts.libs.basic.Data as D;

import mods.zenutils.command.ZenCommand;
import mods.zenutils.command.CommandUtils;
import mods.zenutils.command.IGetTabCompletion;
import crafttweaker.text.ITextComponent;
import crafttweaker.player.IPlayer;

static diffMap as string[]  =["EASY","NORMAL","HARD","LUNATIC","ULTRA"];
static DIFF as int = scripts.Config.DIFF;
function isSurvival()as bool{
    var w = crafttweaker.world.IWorld.getFromID(0);
    var d = w.getCustomWorldData();
    var s as int = d.deepGet("modpack.survival").asInt();
    return s==2;
}
events.onWorldTick(function(event as crafttweaker.event.WorldTickEvent){
    var w = crafttweaker.world.IWorld.getFromID(0);
    if(event.world.isRemote())return;
    var d = w.getCustomWorldData();
    var t = d.deepGet("modpack.difficulty");
    if(isNull(t)){
        w.updateCustomWorldData(
            d.deepSet(DIFF,"modpack.difficulty")
            .deepSet(0,"modpack.survival") //0: Test; 1: Ready to initialize; 2: Normal Survival World
        );
    }
    else{
        var s as int = d.deepGet("modpack.survival").asInt();
        if(t.asInt()!=DIFF && s==2){
            val s1 = game.localize("modpack.general.difficulty.world_error");
            val s2 = "WorldDiff:"~diffMap[t.asInt()];
            val s3 = "GameDiff:"~diffMap[DIFF];
            M.shout(s1);M.shout(s2);M.shout(s3);
            print(s1);print(s2);print(s3);
            M.executeCommand("effect @a minecraft:blindness 2");
            M.executeCommand("effect @a minecraft:slowness 2 5");
            M.executeCommand("effect @a minecraft:mining_fatigue 2 5");
        }
        if(s==1){
            M.executeCommand("effect @a minecraft:blindness 2");
            M.executeCommand("effect @a minecraft:slowness 2 5");
            M.executeCommand("effect @a minecraft:mining_fatigue 2 5");
        }
    }
});
//Commands
val syncDifficulty as ZenCommand = ZenCommand.create("syncDifficulty");
syncDifficulty.requiredPermissionLevel = 0;
syncDifficulty.execute = function(command, server, sender, args) {
    var w = crafttweaker.world.IWorld.getFromID(0);
    var d = w.getCustomWorldData();
    var s as int = d.deepGet("modpack.survival").asInt();
    w.updateCustomWorldData(
        d.deepSet(DIFF,"modpack.difficulty").deepSet(s>0?2:0,"modpack.survival")
    );
};
syncDifficulty.register();
//Initialization
function confirmDifficulty(p as IPlayer)as void{
    var w1 = p.world;
    if(w1.isRemote())return;
    var w = crafttweaker.world.IWorld.getFromID(0);
    var d = w.getCustomWorldData();
    var s as int = d.deepGet("modpack.survival").asInt();
    if(s!=1)return;
    var message = M.localize("modpack.general.difficulty.confirm1")~ITextComponent.fromString(diffMap[DIFF])~M.localize("modpack.general.difficulty.confirm2");
    p.sendRichTextStatusMessage(message, false);
}
events.onPlayerLoggedIn(function(event as crafttweaker.event.PlayerLoggedInEvent){
    confirmDifficulty(event.player);
});
val setTestWorld as ZenCommand = ZenCommand.create("setTestWorld");
setTestWorld.tabCompletionGetters = [scripts.libs.advanced.ZenCommand.boolTab];
setTestWorld.execute = function(command, server, sender, args) {
    var w = crafttweaker.world.IWorld.getFromID(0);
    var d = w.getCustomWorldData();
    var s = 0;
    if(args.length>0){
        if(args[0]=="false"){
            s=1;
        }
    }
    w.updateCustomWorldData(
        d.deepSet(s,"modpack.survival")
    );
    if(s==1){
        confirmDifficulty(CommandUtils.getCommandSenderAsPlayer(sender));
    }
};
setTestWorld.register();