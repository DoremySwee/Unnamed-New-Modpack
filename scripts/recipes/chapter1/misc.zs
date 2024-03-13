#reloadable
#priority -1
import mods.botaniatweaks.Agglomeration as Agg;
import scripts.libs.recipe.Transcript as T;
import scripts.libs.recipe.Mapping as Mp;
import scripts.libs.recipe.Misc as M;
import crafttweaker.item.IItemStack;
import crafttweaker.item.IIngredient;
import crafttweaker.item.IItemDefinition;
//TwigWand
    recipes.remove(<botania:twigwand>);
    recipes.addShaped(<botania:twigwand>.withTag({color1: 5, color2: 13}),[
        [null,<minecraft:stick>],
        [<minecraft:stick>,<minecraft:sapling>]]);
    var twp=<botania:petal:*>;
    var tws=<botania:manaresource:3>;
    recipes.addShaped("re_add_twigwand_recipe",<botania:twigwand>,[
        [null,twp.marked("a"),tws],
        [null,tws,twp.marked("b")],
        [tws,null,null]
    ],function(out,ins,info){
        print(isNull(ins));
        var a = isNull(ins.a)?0:ins.a.metadata;
        var b = isNull(ins.b)?0:ins.b.metadata;
        print(a);
        print(b);
        return <botania:twigwand>.withTag({color1: a, color2: b, boundTileZ: 0, boundTileX: 0, boundTileY: -1});
    },null);

//Select the charcoal block
    if(true){
        var CC=<minecraft:coal:1>;
        var CCB=<chisel:block_charcoal>;
        recipes.addShapeless(CCB,[CC,CC,CC,CC,CC,CC,CC,CC,CC]);
    }

//Builder's wand
    recipes.addShaped(<betterbuilderswands:wandstone>,Mp.read("__R;_S_;S__;",{"R":<botania:livingrock>,"S":<botania:manaresource:3>}));