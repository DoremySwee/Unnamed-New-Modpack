#loader contenttweaker
import scripts.libs.CotLib;
import mods.contenttweaker.AxisAlignedBB;
import mods.contenttweaker.VanillaFactory;
import mods.randomtweaker.cote.ISubTileEntityGenerating;

static AABB_PLATE as AxisAlignedBB = AxisAlignedBB.create(0.0,0.0,0.0,1.0,0.18375,1.0);

CotLib.createItem("alchemical_medium");

//TODOs: Redo the [Heated Netherrack], [Rock of Ignis], add textures for [Color Engine A]