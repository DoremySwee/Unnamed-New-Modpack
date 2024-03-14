#loader contenttweaker
import scripts.libs.CotLib as CL;
import mods.contenttweaker.VanillaFactory;
import mods.randomtweaker.cote.ISubTileEntityGenerating;
//Broken Runes
    static runeNames as string[] = ["aer","aqua","ignis","terra"];
    for name in runeNames {CL.createItem("broken_"~name~"_rune");}
//Flower: Whispee
val flower as ISubTileEntityGenerating = VanillaFactory.createSubTileGenerating("whispee");
    flower.range = 5;
    flower.maxMana = 1000;
    flower.register();
