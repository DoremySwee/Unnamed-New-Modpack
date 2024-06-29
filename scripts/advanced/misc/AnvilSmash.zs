#reloadable
#norun
//Todo
#priority 100000001
import crafttweaker.entity.IEntityDefinition;
import crafttweaker.item.IItemDefinition;
import crafttweaker.item.IIngredient;
import crafttweaker.item.IItemStack;
import crafttweaker.data.IData;
static Recipes as IItemStack[IIngredient] = [] as IItemStack[IIngredient];
function addSmash(output as IItemStack, input as IIngredient){
    Recipes[input] = output;
}
events.