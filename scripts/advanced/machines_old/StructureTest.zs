#reloadable
#priority 114000
#norun
import mods.zenutils.cotx.TileEntityInGame;
import scripts.advanced.machines.Register;
import scripts.libs.advanced.Misc as M;
import scripts.libs.basic.Data as D;
import crafttweaker.world.IBlockPos;
import crafttweaker.world.IWorld;
import crafttweaker.data.IData;

// Related Algorithm: Nearest Neighbor Search
// However, we are currently considering the problem for a relatively small data size, so we don't need the algorithm

//Config
    static TEST_PERIOD_WHILE_WORKING as int = 20; //unit: gt
    static ENABLE_UPDATE_CHECKS as bool = true; //This means if a block update is found, the neighboring machines will check if they are still completed

/*
static STRUCTURE_TEST_FUNCTIONS as function(IWorld,IBlockPos)int [string] = {} as function(IWorld,IBlockPos)int [string];
function registerStructureTestFunction(id as string, f as function(IWorld,IBlockPos)int){
    //returnValue = 0: failed, 1: success
    STRUCTURE_TEST_FUNCTIONS[id] = f;
}

function getOnTickCheck(id as string){
    val f = STRUCTURE_TEST_FUNCTIONS[id];
    return function(te as TileEntityInGame, world as IWorld, pos as IBlockPos)as bool{
        if(te.data.isRunning.asBool() && te.data.runningTicker.asInt()%TEST_PERIOD_WHILE_WORKING==0) return f(world,pos);
        if(te.data.recipeEnding.asBool()) return f(world,pos);
        return true;
    };
}
*
//if(ENABLE_UPDATE_CHECKS)
events.onBlockNeighborNotify(function(event as crafttweaker.event.BlockNeighborNotifyEvent){
    var world = event.world;
    var pos = event.position;
    var block = event.block;
    M.shout("AAA");
});*/