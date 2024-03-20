#reloadable
import scripts.libs.advanced.ParticleGenerator as FX;
import scripts.libs.basic.Vector3D as V;
import scripts.libs.advanced.Misc as M;
import crafttweaker.player.IPlayer;
import crafttweaker.world.IWorld;
import crafttweaker.data.IData;

import mods.zenutils.command.ZenCommand;
import mods.zenutils.command.CommandUtils;
import mods.zenutils.command.IGetTabCompletion;

//Interpolate [x^0.7]
static POWTEMPA as double[]=[]as double[];
for i in 0 to 3000{
    POWTEMPA+=pow(0.001*i,0.7);
}
static powAF as function(double)double = function(x as double)as double{
    if(x<0)return -1.0;
    if(x==0)return 0.0;
    if(x==1)return 1.0;
    if(x==3)return 27.0;
    if(x>3)return pow(x,0.7);
    var left = V.floor(x*1000);
    var t1 = x*1000-left;
    var yl = POWTEMPA[left];
    var yr = POWTEMPA[left+1];
    var y = t1*yr + (1.0-t1)*yl;
    return y;
};

static FISH as FX.FXGenerator = FX.FXGenerator("firework_fish")
    .addAging(1280)
    .updateDefaultData({
        "x":0.0,  "y":0.0,  "z":0.0,
        "initialized":false, "effectiveRadius":300.0,
        "renderInterval":2,"renderTime":1,
        //Its size
        "parts":20,"partInterval":5,//length
        "widthNum":4, "width":5.0,//width
        //Movement. Angle:Degree, Time:GT, 【Velocity:Block/s】
        "maxAngle":30.0,"period":340.0,"velocity":3.0,"defaultMovement":true,
        "color":-1 as int,"size":2.0
    }as IData)
    //init
    .addTick(function(world as IWorld, data as IData)as IData{
        if(data.initialized.asBool())return data;
        var data2 as IData = IData.createEmptyMutableDataMap();
        var pos = V.scale(V.randomUnitVector(world),70+world.random.nextInt(30)+world.random.nextInt(70));
        var vs = data.velocity.asDouble()/20; //Block/gt
        var v1 = V.rot(V.scale(V.unify([pos[1],-pos[0],pos[2]]),vs),pos,world.random.nextInt(360));
        var v2 = V.scale(V.unify(V.cross(pos,v1)),vs);
        pos = V.add(V.add(pos,V.scale(v1,-0.5*data.lifeLimit.asInt())),[0,70.0,0]as double[]);
        data2 = data2 + V.asData(v1,"v1") + V.asData(v2,"v2");

        var n = data.parts.asInt()*data.partInterval.asInt();
        var data3 as IData = IData.createEmptyMutableDataMap();
        for i in 0 to n{
            var time = n-i;
            var phase = time / data.period.asDouble();
            var theta = V.sinf (phase*360) * data.maxAngle.asDouble();
            var v = V.disc(v1,v2,theta);
            pos = V.add(pos,v);
            data3 = data3 + V.asData(pos,"posRec"~i);
        }
        if(data.color.asInt()<0){
            data2 = data2 + {"color":M.fromDoubleRGB(V.randomUnitVector(world))};
        }

        return data+data2+{"posRec":data3,"initialized":true}+V.asData(pos);
    })
    //Default Moving (The fish is initialized by default moving)
    .addTick(function(world as IWorld, data as IData)as IData{
        if(!data.defaultMovement.asBool())return data;

        var pos = V.fromData(data);
        var v1 = V.fromData(data,"v1");
        var v2 = V.fromData(data,"v2");
        var time = data.life.asInt();
        var phase = 1.0*time / data.period.asDouble();
        var theta = V.sinf (phase*360) * data.maxAngle.asDouble();
        var v = V.disc(v1,v2,theta);
        pos = V.add(pos,v);
        
        var n = data.parts.asInt()*data.partInterval.asInt();
        var i = time%n;
        var posRec as IData = data.posRec + V.asData(pos,"posRec"~i);
        var resultData as IData = data + V.asData(pos) + {"posRec":posRec};
        return resultData;
    })
    .setRender(function(player as IPlayer, data as IData)as void{
        if(data.life.asInt()%data.renderInterval.asInt()>0)return;
        var posRec = data.posRec;
        for i in 1 to data.parts.asInt(){
            var recI = i*data.partInterval.asInt();
            var x = 1.0 - 1.0*i / data.parts.asInt();
            var m as int = data.widthNum.asInt();
            var ys as double[] = [] as double[];
                //Head, Body, Tail
                for j in ((1-m) to m){
                    var t1 = (40/3.1415*180);
                    var yt = 1.0 * j / m;
                    if(x>0.85 && 5.0*(x - 0.85)>V.abs(yt))continue;
                    ys = ys + (yt * V.sinf( powAF(x*t1) ));
                }
                //Wing
                var y1 = 1.0 + (x - 0.4)*2.1;
                var y2 = 1.0 + (x - 0.5)*2.9;
                if(y1 > y2 && y1>0.5){
                    for j in V.floor(y2*m) to V.floor(y1*m)+1{
                        var yt = 1.0*j/m;
                        ys = ys + yt; 
                        ys = ys + (-yt); 
                    }
                }
            //Render
            var n = data.parts.asInt()*data.partInterval.asInt();
            var t2 = recI+data.life.asInt();
            var indA = (n+t2- 1)%n;
            var ind = t2%n;
            var p0 = V.fromData(posRec,"posRec"~ind);
            var dv = V.subtract(p0,V.fromData(posRec,"posRec"~indA));
            var norm = V.unify(V.cross(V.fromData(data,"v1"),V.fromData(data,"v2")));
            var vy = V.scale(V.unify(V.rot(dv,norm,90.0)),data.width.asDouble());

            for y in ys{
                //TODO: the fish should appear and disappear smoothly, by changing the color
                var p = V.add(p0,V.scale(vy,y));
                
                var d2 = data + V.asData(p) + {"r":data.size.asDouble(),"a":data.renderInterval.asInt()*2} as IData;
                var t3 = 1.0*data.life.asInt() / data.lifeLimit.asInt();
                if(t3>0.8) t3=1.0-t3;
                if(t3<0.2){
                    var ratio = t3*5;
                    var colorDouble3 = V.scale(M.getDoubleRGB(data.color.asInt()),t3);
                    var colorInt1 = M.fromDoubleRGB(colorDouble3);
                    d2 = d2 + {"color":colorInt1};
                }
                for j in (0 to data.renderTime.asInt()){
                    M.createFX(d2);
                }
            }
        }
    })
    .regi();
//TODO: more fireworks

static FIREWORKS as FX.FXGenerator[string] = {
    "fish": FISH
} as FX.FXGenerator[string];
static DL as int = scripts.Config.DECORATION_LEVEL;

val spawnFireWork as ZenCommand = ZenCommand.create("fireWork");
    spawnFireWork.requiredPermissionLevel = 0;
    spawnFireWork.tabCompletionGetters = [
        function(server, sender, pos) {
            return mods.zenutils.StringList.create(["count","spawn"]);
        }  as IGetTabCompletion,
        function(server, sender, pos) {
            return mods.zenutils.StringList.create(FIREWORKS.keys);
        }  as IGetTabCompletion];

    spawnFireWork.execute = function(command, server, sender, args) {
        var player = CommandUtils.getCommandSenderAsPlayer(sender);
        if(args.length>1){
            var name = args[1];
            var fx = FIREWORKS[name];
            if(args[0]=="spawn"){
                fx.create(player.world,{});
                player.sendChat("Success!");
            }
            else if (args[1]=="count"){
                player.sendChat("There are "~fx.countObjects(player.world.dimension)~" "~name~" in this world, currently");
            }
        }
        else{
            player.sendChat("Missing arguments!");
        }
    };
spawnFireWork.register();

events.onWorldTick(function(event as crafttweaker.event.WorldTickEvent){
    var world = event.world;
    if(DL<1)return;
    if(world.remote) return;
    if(world.dimension!=0) return;
    //fish
    if(world.random.nextInt(3000)<1){
        if(FISH.countObjects(world.dimension)<DL)FISH.create(world,{});
    }
    
});
