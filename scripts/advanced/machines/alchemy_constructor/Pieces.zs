#reloadable
#priority 10007

import crafttweaker.block.IBlockState;
import crafttweaker.world.IWorld;
import crafttweaker.world.IBlockPos;
import crafttweaker.item.IItemStack;
import crafttweaker.item.IIngredient;
import crafttweaker.liquid.ILiquidStack;
import scripts.libs.recipe.Transcript as T;
import scripts.advanced.machines.alchemy_constructor.Medium.createMedium;
import scripts.libs.advanced.Hungarian;

zenClass Piece {
    val predicate as function(IWorld,IBlockPos)bool;
    val clear as function(IWorld,IBlockPos)void;

    zenConstructor(predicate as function(IWorld,IBlockPos)bool, clear as function(IWorld,IBlockPos)void) {
        this.predicate = predicate;
        this.clear = clear;
    }
}

zenClass CastingTable {
    val item as IIngredient;
    val fluid as ILiquidStack;
    val medium as IItemStack;

    zenConstructor(item as IIngredient, fluid as ILiquidStack) {
        this.item = item;
        this.fluid = fluid;
        this.medium = createMedium("Casting", [item], [fluid]);
        T.tic.casting(this.medium, item, fluid, 80);
    }

    function isWorking(world as IWorld, pos as IBlockPos) as bool {
        val inv = world.getItemHandler(pos, down);
        val fluidInv = world.getLiquidHandler(pos, down);
        val fluidContent = fluidInv.tankProperties[0].contents;
        val itemMatched = item.matches(inv.getStackInSlot(0));
        val fluidMatched = !isNull(fluidContent) && fluid.commandString == fluidContent.commandString;
        return itemMatched && fluidMatched;
    }

    function clear(world as IWorld, pos as IBlockPos) as void {
        val inv = world.getItemHandler(pos);
        inv.setStackInSlot(0, null);
        world.setBlockState(<blockstate:minecraft:air>, pos);
        world.catenation()
            .then(function(w, ctx) {
                w.setBlockState(<blockstate:tconstruct:casting:type=table>, pos);
            })
            .start();
    }

    function toPiece() as Piece {
        return Piece(function(world as IWorld, pos as IBlockPos) as bool {
            return this.isWorking(world, pos);
        }, function(world as IWorld, pos as IBlockPos) as void {
            this.clear(world, pos);
        });
    }
}

zenClass RuneAltar {
    val inputs as IIngredient[];
    val medium as IItemStack;

    zenConstructor(inputs as IIngredient[]) {
        this.inputs = inputs;
        this.medium = createMedium("RuneAltar", inputs, []);
        T.bot.runeAltar(this.medium, inputs, 1000);
    }

    function isWorking(world as IWorld, pos as IBlockPos) as bool {
        val mana = world.getBlock(pos).data.mana.asInt();
        if (mana == 0) {
            print("invalid mana");
            return false;
        }
        val inv = world.getItemHandler(pos);
        var invItems as [IItemStack] = [] as [IItemStack];
        for item in inv {
            if (!isNull(item)) {
                invItems += item;
            }
        }
        return Hungarian.testShapeless(inputs, invItems);
    }

    function clear(world as IWorld, pos as IBlockPos) as void {
        val inv = world.getItemHandler(pos);
        for i in 0 .. inv.size {
            inv.setStackInSlot(i, null);
        }
    }

    function toPiece() as Piece {
        return Piece(function(world as IWorld, pos as IBlockPos) as bool {
            return this.isWorking(world, pos);
        }, function(world as IWorld, pos as IBlockPos) as void {
            this.clear(world, pos);
        });
    }
}
