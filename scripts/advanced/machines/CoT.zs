#loader contenttweaker
import scripts.libs.CotLib as CL;
import mods.contenttweaker.AxisAlignedBB;
import mods.contenttweaker.VanillaFactory;
import mods.randomtweaker.cote.ISubTileEntityGenerating;

static AABB_PLATE as AxisAlignedBB = AxisAlignedBB.create(0.0,0.0,0.0,1.0,0.18375,1.0);

//TODOs: Redo the [Heated Netherrack], [Rock of Ignis], add textures for [Color Engine A]

//Color_Engine_B
val Color_Engine_B = VanillaFactory.createExpandBlock("color_engine_b_real", <blockmaterial:iron>);
    Color_Engine_B.tileEntity = CL.createTileEntity("color_engine_b_real");
    Color_Engine_B.axisAlignedBB = AABB_PLATE;
    Color_Engine_B.fullBlock = false;
    //Color_Engine_B.translucent = true;
    Color_Engine_B.register();