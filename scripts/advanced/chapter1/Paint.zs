#reloadable
// By Jey_yz
import crafttweaker.event.WorldTickEvent;
import crafttweaker.world.IWorld;
import crafttweaker.world.IBlockPos;
import crafttweaker.block.IBlockState;
import crafttweaker.block.IBlock;
import crafttweaker.item.IItemStack;
import crafttweaker.world.IVector3d;


val colorless_blocks as IItemStack[string] = {'minecraft:glass':<minecraft:stained_glass>,'minecraft:hardened_clay':<minecraft:stained_hardened_clay>,'minecraft:glass_pane':<minecraft:stained_glass_pane>};
val metaTocolor as string[int] = {0:'white',1:'orange',2:'magenta',3:'light_blue',4:'yellow',5:'lime',6:'pink',7:'gray',8:'silver',9:'cyan',10:'purple',11:'blue',12:'brown',13:'green',14:'red',15:'black'};
val num as int[] = [-1,0,1];

events.onWorldTick(function(event as crafttweaker.event.WorldTickEvent){
    var world as IWorld=event.world;
    var poses as IBlockPos[] = [];
    var poses_checked as IBlockPos[] = [];
    for e in world.getEntities(){
        if(isNull(e.definition))continue;
        if(e.definition.id!="botania:mana_burst")continue;
        if(isNull(e.nbt))continue;
        if(isNull(e.nbt.lensStack))continue;
        if(isNull(e.nbt.lensStack.tag))continue;
        if(isNull(e.nbt.lensStack.tag.color))continue;

        var begin = IVector3d.create(e.x,e.y,e.z);
        var trace = IVector3d.create(e.x+e.motionX,e.y+e.motionY,e.z+e.motionZ);
        var next_pos = IBlockPos.create(e.x,e.y,e.z);
        if(isNull(world.rayTraceBlocks(begin,trace))){
            continue;
        }else{
            next_pos = world.rayTraceBlocks(begin,trace).blockPos;
        }
        var next_block = world.getBlock(next_pos);

        if(colorless_blocks has next_block.definition.id){
	        poses += next_pos;
        }else{continue;}
        var original_block = next_block.definition.id;
        while(poses_checked.length<1000){
            for next_p in poses{
	            if(!(poses_checked has next_p))poses_checked+=next_p;
                for a in num{
                    for b in num{
                        for c in num{
                            var shift_pos_count = 0;
                            for i in ([a,b,c] as int[]){if(i==0)shift_pos_count+=1;}
                            if(shift_pos_count<2)continue;
                            var new_pos as IBlockPos = IBlockPos.create(next_p.x+a,next_p.y+b,next_p.z+c);
                            if(poses has new_pos)continue;
                            if(world.getBlock(new_pos).definition.id != original_block)continue;
                            poses+=new_pos;
                            if(poses.length==poses_checked.length)break;
	                    }
                    }
                }
	            if(poses.length==poses_checked.length)break;
            }
            if(poses.length==poses_checked.length)break;
        }
        for new_p in poses_checked{
            var new_block  =((colorless_blocks[original_block].definition.makeStack(e.nbt.lensStack.tag.color)) as IBlock).definition.defaultState;
            new_block = new_block.withProperty('color',metaTocolor[e.nbt.lensStack.tag.color]);
            world.setBlockState(new_block as IBlockState,new_p);
        }

        world.removeEntity(e);
    }
});


val colorless as IItemStack[] = [<minecraft:glass>,<minecraft:hardened_clay>,<minecraft:glass_pane>];
for i in colorless{i.addTooltip(game.localize("modpack.tooltip.colorable"));}
//zh.cn.lang:modpack.tooltip.colorable=现在可以使用 魔力透镜:涂色 染色
