#reloadable
#priority 2000
import crafttweaker.item.IItemStack;
import crafttweaker.item.IIngredient;
import scripts.libs.recipe.Transcript as T;

val exn = loadedMods["exnihilocreatio"];
static whiteList as IIngredient = <exnihilocreatio:crook_bone> | <exnihilocreatio:crook_wood> | <exnihilocreatio:item_mesh:1> | <exnihilocreatio:block_sieve> | <exnihilocreatio:hammer_diamond> | <exnihilocreatio:hammer_stone> | <exnihilocreatio:hammer_wood> | <exnihilocreatio:hammer_gold> | <exnihilocreatio:hammer_iron>;
for item in exn.items{
    if(whiteList.matches(item))continue;
    recipes.remove(item);
}
mods.exnihilocreatio.Compost.removeAll();
mods.exnihilocreatio.Sieve.removeAll();
mods.exnihilocreatio.Hammer.removeAll();
T.exN.hammerChain([<minecraft:cobblestone>,<minecraft:gravel>,<minecraft:sand>,<exnihilocreatio:block_dust>]as IItemStack[]);
T.exN.hammer([<contenttweaker:shard_ordo>], <minecraft:stone_slab>*2, <blockstate:minecraft:double_stone_slab>);
T.exN.hammer([<contenttweaker:shard_aer>], <minecraft:stone_slab:1>*2, <blockstate:minecraft:double_stone_slab>.block.definition.getStateFromMeta(1));
T.exN.hammer([<contenttweaker:shard_aqua>], <minecraft:ice>);
T.exN.hammer([<contenttweaker:shard_ignis>], <minecraft:nether_brick>);
T.exN.hammer([<contenttweaker:shard_perditio>], <minecraft:tnt>);
T.exN.hammer([<contenttweaker:shard_terra>], <minecraft:grass>);