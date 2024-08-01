#reloadable
#priority 10000

import crafttweaker.item.IItemStack;
import crafttweaker.block.IBlockStateMatcher;
import crafttweaker.block.IBlockState;
import crafttweaker.world.IWorld;
import crafttweaker.world.IBlockPos;
import mods.modularmachinery.MMEvents;
import mods.modularmachinery.RecipeBuilder;
import mods.modularmachinery.RecipeCheckEvent;
import scripts.advanced.machines.alchemy_constructor.Pieces;
import scripts.libs.advanced.Hungarian;

zenClass Recipe {
    val output as IItemStack;
    val input as IItemStack;
    val name as string;

    // builder arguments
    var casting as Pieces.CastingTable;
    var runeAltar as Pieces.RuneAltar;

    // internal logic pieces
    var machineSlots as IBlockStateMatcher[] = [];
    var machineSlotPieces as Pieces.Piece[] = [];

    zenConstructor(name as string, input as IItemStack, output as IItemStack) {
        this.name = name;
        this.input = input;
        this.output = output;
    }

    function register() as void {
        val builder = RecipeBuilder.newBuilder(name, "alchemy_constructor", 20);
        builder.addItemInput(input);
        builder.addItemOutput(output);
        if (!isNull(casting)) {
            machineSlots += <blockstate:tconstruct:casting:type=table>;
            machineSlotPieces += casting.toPiece();
            builder.addCatalystInput(casting.medium, [], []).setChance(0);
        }
        if (!isNull(runeAltar)) {
            machineSlots += <blockstate:botania:runealtar>;
            machineSlotPieces += runeAltar.toPiece();
            builder.addCatalystInput(runeAltar.medium, [], []).setChance(0);
        }
        builder.addPostCheckHandler(function(event as RecipeCheckEvent) {
            val controller = event.controller;
            val centerPos = controller.pos.getOffset(controller.facing.opposite, 1);
            val world = controller.world;
            val size = controller.getDynamicPattern("line").size;
            var machines as [IBlockState] = [] as [IBlockState];
            for i in 0 .. size {
                val machinePos = centerPos.up(i + 1);
                machines += world.getBlockState(machinePos);
            }
            val matchResult as int[] = Hungarian.matchBlocks(machineSlots, machines);
            for i in 0 .. machineSlots.length {
                print(matchResult[i]);
                if (matchResult[i] < 0) {
                    event.setFailed("Missing machines");
                    return;
                }
            }
            for i in 0 .. machineSlots.length {
                val machineIndex = matchResult[i];
                val piece = machineSlotPieces[i];
                print("checking recipe");
                // print(typeof(piece.predicate));
                if (!piece.predicate(world, centerPos.up(machineIndex + 1))) {
                    event.setFailed("A machine is not working on the required recipe");
                    return;
                }
            }
            print("success");
            for i in 0 .. machineSlots.length {
                val machineIndex = matchResult[i];
                val piece = machineSlotPieces[i];
                piece.clear(world, centerPos.up(machineIndex + 1));
            }
        });
        builder.build();
    }
}

val recipe = Recipe("test", <appliedenergistics2:material:35>, <appliedenergistics2:material:37>);
recipe.casting = Pieces.CastingTable(<minecraft:apple>, <liquid:iron> * 144);
recipe.runeAltar = Pieces.RuneAltar([<minecraft:apple>, <minecraft:stone>]);
recipe.register();
