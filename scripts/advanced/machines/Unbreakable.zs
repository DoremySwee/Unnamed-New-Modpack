#reloadable
import crafttweaker.item.IItemStack;
import crafttweaker.block.IBlock;
static UNBREAKABLE_BLOCKS as IItemStack[] = [<modularmachinery:color_engine_a_controller>] as IItemStack[];
for item in UNBREAKABLE_BLOCKS{
    var blockDef = (item as IBlock).definition;
    blockDef.setUnbreakable();
    blockDef.resistance=1919810.0;
}