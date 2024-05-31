#reloadable
import scripts.libs.advanced.Misc as M;
import scripts.libs.basic.Vector3D as V;
import crafttweaker.entity.IEntityItem;
import crafttweaker.item.IItemStack;
import crafttweaker.world.IWorld;
import crafttweaker.block.IBlock;

static shard as IItemStack = <contenttweaker:shard_nether>;
mods.jei.JEI.addDescription([shard],game.localize("modpack.jei.vanilla.nether_portal.description1"));

events.onEntityTravelToDimension(function(event as crafttweaker.event.EntityTravelToDimensionEvent){
    if(event.dimension != -1) return;
    event.cancel();
    var e = event.entity;
    var world as IWorld = e.world;
    if(world.remote)return;
    if(e instanceof IEntityItem){
        var p0 = V.getPos(e);
        var p1 = V.add(p0, V.randomVector(world,world.random.nextDouble(2,5)));
        var p = V.asBlockPos(p1);
        //M.shout(p.x);
        if(M.checkBlock(world.getBlock(p),"minecraft:obsidian")){
            world.removeEntity(e);
            world.performExplosion(null, p1[0],p1[1],p1[2], 0.7, false, true);
            world.setBlockState(<blockstate:minecraft:air>,null,p);
            world.spawnEntity((shard*1).createEntityItem(world, p1[0] as float, p1[1] as float, p1[2] as float));
        }
    }
});