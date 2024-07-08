#reloadable
// By Jey_yz
import crafttweaker.event.EntityJoinWorldEvent;
import crafttweaker.world.IWorld;
import crafttweaker.world.IBlockPos;
import crafttweaker.block.IBlockState;
import crafttweaker.block.IBlock;
import crafttweaker.item.IItemStack;
import crafttweaker.world.IVector3d;


val colorlessBlocks as IBlockState[string] = {
    'minecraft:glass':<blockstate:minecraft:stained_glass>,
    'minecraft:hardened_clay':<blockstate:minecraft:stained_hardened_clay>,
    'minecraft:glass_pane':<blockstate:minecraft:stained_glass_pane>};
val metaTocolor as string[int] = {
    0:'white',
    1:'orange',
    2:'magenta',
    3:'light_blue',
    4:'yellow',
    5:'lime',
    6:'pink',
    7:'gray',
    8:'silver',
    9:'cyan',
    10:'purple',
    11:'blue',
    12:'brown',
    13:'green',
    14:'red',
    15:'black'
};
val num as int[] = [-1,0,1];

events.register(function(event as EntityJoinWorldEvent) {
    val entity = event.entity;
    val world = entity.world;
    if (world.remote || isNull(entity.definition) || entity.definition.id != "botania:mana_burst" || isNull(entity.nbt.deepGet("lensStack.tag.color"))) {
        return;
    }
    val color = metaTocolor[entity.nbt.deepGet("lensStack.tag.color").asInt()];
    world.catenation()
        .sleepUntil(function(w, ctx) {
            if (!entity.native.addedToWorld || !entity.alive) {
                ctx.catenation.stop();
            }
            val begin = IVector3d.create(entity.x, entity.y, entity.z);
            val motion = IVector3d.create(entity.motionX, entity.motionY, entity.motionZ);
            val trace = begin.add(motion);
            val result = w.rayTraceBlocks(begin, trace);
            if (!isNull(result) && result.isBlock) {
                val pos = result.blockPos;
                ctx.data = [pos.x, pos.y, pos.z] as int[];
                return true;
            } else {
                return false;
            }
        })
        .then(function(w, ctx) {
            var poses as IBlockPos[] = [];
            var posesChecked as IBlockPos[] = [];
            var nextPos = IBlockPos.create(ctx.data[0], ctx.data[1], ctx.data[2]);
            var nextBlock = w.getBlock(nextPos);
            val originalBlock = nextBlock.definition.id;
            print(originalBlock); 
            if (colorlessBlocks.keys has originalBlock) {
                poses += nextPos;
            } else return;
            while(posesChecked.length<1000){
                for nextP in poses{
                    if (!(posesChecked has nextP)) {
                        posesChecked += nextP;
                    }
                    for x in num{
                        for y in num{
                            for z in num{
                                var shiftPosCount = 0;
                                for i in ([x,y,z] as int[]) {
                                    if (i == 0) {
                                        shiftPosCount += 1;
                                    }
                                }
                                if (shiftPosCount < 2) continue;
                                val newPos as IBlockPos = IBlockPos.create(nextP.x + x, nextP.y + y, nextP.z + z);
                                if (poses has newPos)continue;
                                if (w.getBlock(newPos).definition.id != originalBlock)continue;
                                poses += newPos;
                                if (poses.length == posesChecked.length) break;
                            }
                        }
                    }
                    if (poses.length == posesChecked.length) break;
                }
                if (poses.length == posesChecked.length) break;
            }
            var newBlock = colorlessBlocks[originalBlock].withProperty('color', color);
            for newP in posesChecked{
                w.setBlockState(newBlock, newP);
            }
        })
        .start();
});


val colorless as IItemStack[] = [<minecraft:glass>,<minecraft:hardened_clay>,<minecraft:glass_pane>];
for i in colorless{i.addTooltip(game.localize("modpack.tooltip.colorable"));}
//zh.cn.lang:modpack.tooltip.colorable=现在可以使用 魔力透镜:涂色 染色
