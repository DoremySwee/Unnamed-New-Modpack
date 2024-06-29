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
// mods.exnihilocreatio.Hammer.removeAll();
//mods.exnihilocreatio.Hammer.addRecipe(input as IIngredient, output as IItemStack, toolLevel as Int, chance as Float, fortuneChance as Float);
/*
T.exN.hammer(<minecraft:gravel>, <minecraft:cobblestone>);
T.exN.hammer(<minecraft:sand>, <minecraft:gravel>);
T.exN.hammer(<exnihilocreatio:block_dust>, <minecraft:sand>);
T.exN.hammer();*/

// T.exN.hammer(<contenttweaker:shard_ordo>, <minecraft:double_stone_slab:0>);

