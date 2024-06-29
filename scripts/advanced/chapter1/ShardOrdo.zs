#reloadable
#norun
import crafttweaker.event.PlayerBreakSpeedEvent;
import crafttweaker.event.BlockBreakEvent;
import crafttweaker.item.IItemStack;

static shard as IItemStack = <contenttweaker:shard_ordo>;
mods.jei.JEI.addDescription([shard],game.localize("modpack.jei.exnihilo.hammer_double_stone_slab.description1"));

events.register(function(event as PlayerBreakSpeedEvent) {
    if (<blockstate:minecraft:double_stone_slab>.matches(event.blockState)) {
        val tool = event.player.currentItem;
        if (<exnihilocreatio:hammer_wood:*>.matches(tool)) {
            event.newSpeed = 2.0f;
        } else if (<exnihilocreatio:hammer_stone:*>.matches(tool)) {
            event.newSpeed = 4.0f;
        } else if (<exnihilocreatio:hammer_iron:*>.matches(tool)) {
            event.newSpeed = 6.0f;
        } else if (<exnihilocreatio:hammer_diamond:*>.matches(tool)) {
            event.newSpeed = 8.0f;
        } else if (<exnihilocreatio:hammer_gold:*>.matches(tool)) {
            event.newSpeed = 12.0f;
        }
    }
});

events.register(function(event as BlockBreakEvent) {
    if (<blockstate:minecraft:double_stone_slab>.matches(event.blockState) && event.isPlayer) {
        val tool = event.player.currentItem;
        val world = event.world;
        if (tool.definition.id.startsWith("exnihilocreatio:hammer")) {
            world.spawnEntity(shard.createEntityItem(world, event.x + 0.5f, event.y + 0.5f, event.z + 0.5f));
        }
    }
});
