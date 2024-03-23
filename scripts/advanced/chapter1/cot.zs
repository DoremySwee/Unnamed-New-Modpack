#loader contenttweaker
import scripts.libs.CotLib as CL;
import mods.contenttweaker.VanillaFactory;
import mods.randomtweaker.cote.ISubTileEntityGenerating;
//Flower: Whispee
val flower as ISubTileEntityGenerating = VanillaFactory.createSubTileGenerating("whispee");
    flower.range = 5;
    flower.maxMana = 1000;
    flower.register();
