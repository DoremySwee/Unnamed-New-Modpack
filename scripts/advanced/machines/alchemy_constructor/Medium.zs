#reloadable
#priority 10008

import crafttweaker.item.IItemStack;
import crafttweaker.item.IIngredient;
import crafttweaker.liquid.ILiquidStack;
import mods.jei.JEI;

static medium as IItemStack = <contenttweaker:alchemical_medium>;

JEI.addItemNBTSubtype(medium);
medium.addAdvancedTooltip(function(item) {
    if (item.hasTag) {
        return "key: " ~ item.tag.key.asString();
    } else {
        return null;
    }
});

function createMedium(prefix as string, itemKeys as IIngredient[], fluidKeys as ILiquidStack[]) as IItemStack {
    var s as string = prefix;
    for item in itemKeys {
        s ~= item.commandString;
    }
    for fluid in fluidKeys {
        s ~= fluid.commandString;
    }
    return medium.withTag({key: s.hashCode()});
}
