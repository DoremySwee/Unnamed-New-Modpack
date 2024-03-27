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
static DL as int = scripts.Config.DECORATION_LEVEL;
static DCOEF as int = ([0,1,3,10,30]as int[])[DL] as int;
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
        "renderInterval":5,"renderTime":1,
        //Its size
        "parts":16,"partInterval":7,//length
        "widthNum":4, "width":8.0,//width
        //Movement. Angle:Degree, Time:GT, 【Velocity:Block/s】
        "maxAngle":30.0,"period":340.0,"velocity":5.0,"defaultMovement":true,
        "color":-1 as int,"size":2.8
    }as IData)
    //init
    .addTick(function(world as IWorld, data as IData)as IData{
        if(data.initialized.asBool())return data;
        var data2 as IData = IData.createEmptyMutableDataMap();
        var pos = V.scale(V.randomUnitVector(world),60+world.random.nextInt(30)+world.random.nextInt(40));
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
            data2 = data2 + {"color":M.fromDoubleRGB(V.randomUnitPositiveVector(world))};
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
                
                var d2 = data + V.asData(p) + {"r":data.size.asDouble(),"a":data.renderInterval.asInt()*1.2} as IData;
                var t3 = 1.0*data.life.asInt() / data.lifeLimit.asInt();
                if(t3>0.8) t3=1.0-t3;
                if(t3<0.2){
                    var colorDouble3 = V.scale(M.getDoubleRGB(data.color.asInt()),t3*5);
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

static COMET as FX.FXGenerator=FX.LinearOrb.copy("firework_comet")
    .updateDefaultData({"lifeLimit":400,"renderTime":5,"renderInterval":1,"effectiveRadius":440,"color":0xFFFFFF,"colli":false,"omega":3.77,"branch":3,"color2":0x77CCFF,"initialized":false})
    //init
    .addTick(function(world as IWorld,data as IData)as IData{
        if(data.initialized.asBool())return data;
        var pos = V.add([0.0,260.0,0],V.stretch(V.randomUnitVector(world),[200.0,10.0,200.0]));
        var v = V.add([0.0,-2.0,0],V.stretch(V.randomUnitVector(world),[1.6,0.3,1.6]));
        return data+V.asData(pos)+V.asData(v,"v")+{"initialized":true};
    })
    .addTick(function(world as IWorld,data as IData)as IData{
        var pos = V.readFromData(data);
        var newDat as IData = IData.createEmptyMutableDataMap();
        var life as int = data.life.asInt();
        var v = V.unify(V.readFromData(data,"v"));
        if(life%20==0){
            var x = V.rot(v,V.randomUnitVector(world),V.randDouble(75.0,105.0,world));
            var pl = world.getClosestPlayer(pos[0],pos[1],pos[2],200,false);
            if(!isNull(pl) && V.randDouble(0,1,world)<0.3){
                x=V.unify(V.subtract(V.getPos(pl),pos));
                if(V.randDouble(0,1,world)<0.9)x=V.rot(x,V.randomUnitVector(world),V.randDouble(-15,15,world)+V.randDouble(-15,15,world));
            }
            var y = V.rot(v,V.randomUnitVector(world),V.randDouble(75.0,105.0,world));
            var dt = V.randDouble(60,300,world);
            var colors as int[]= [0x0000FF,0xAAAAFF,0xFF77FF,0xFF00FF];
            var color as int= colors[world.random.nextInt(4)];
            for i in 0 to 70{
                var t = 360.0/70*i;
                var v0 = V.disc(x,y,t);
                var a = V.scale(V.disc(x,y,t),0.05);
                var size = V.randDouble(1.5,3.0,world);
                FX.AcclOrb.create(world,V.asData(pos)+V.asData(v0,"v")+V.asData(a,"a")+{
                    "lifeLimit":120,"renderSize":size,"size":size*1.2,"color":color,"renderTime":1,"renderInterval":5,"effectiveRadius":400,"colli":false
                });
            }
        }
        var coV = V.unify([v[1],-v[0],v[2]]);
        var coV2 = V.unify(V.cross(v,coV));
        var t0 = data.omega.asDouble()*data.life.asInt();
        for i in 0 to (data.branch.asInt()){
            //M.shout("AAAAAAA");
            t0 = t0 + 360.0/(data.branch.asInt());
            var v2 = V.scale(V.disc(coV,coV2,t0),0.08);
            var size = V.randDouble(1.5,3.0,world);
            FX.LinearOrb.create(world,V.asData(pos)+V.asData(v2,"v")+{
                "lifeLimit":120,"renderSize":size,"size":size*1.2,"color":data.color2,"renderTime":1,"renderInterval":5,"effectiveRadius":400,"colli":false
            });
        }
        return data;
    })
    .setRender(function(player as IPlayer, data as IData)as void{
        var world as IWorld=player.world;
        for i in 0 to 7{
            M.createFX(
                data+{"r":data.size,"a":40}+V.asData(V.scale(V.randomUnitVector(world),0.07),"v")+
                V.asData(V.add(V.scale(V.randomUnitVector(world),0.5),V.readFromData(data)))
            );
        }
    }).regi();
static ROLL1 as FX.FXGenerator = FX.FXGenerator("firework_roll1")
    .updateDefaultData({
        "renderTime":5,"renderInterval":11-DL*2,"effectiveRadius":440,"color":0x8833FF,"colli":false,
        "x":0,"y":0,"z":0,"initialized":false
    })
    .addAging(800)
    //init
    .addTick(function(world as IWorld,data as IData)as IData{
        if(data.initialized.asBool())return data;
        //w: omega; t:theta
        var w1 = V.scale(V.randomUnitVector(world),0.02*(10+world.random.nextInt(10)));
        var w2 = V.scale(V.randomUnitVector(world),0.02*(10+world.random.nextInt(10)));
        var t1 = V.scale(V.randomUnitVector(world),100000);
        var t2 = V.scale(V.randomUnitVector(world),100000);
        //M.shout(V.asString(t1));
        return data+{"initialized":true}+V.asData(w1,"w1")+V.asData(w2,"w2")+V.asData(t1,"t1")+V.asData(t2,"t2");
            //+{"v1":world.random.nextDouble(2,4.1),"v2":world.random.nextDouble(2,4.1),"vChangePeriod":3*world.random.nextInt(50,110)};
    })
    .addTick(function(world as IWorld,data as IData)as IData{
        var w1 = V.readFromData(data,"w1");
        var w2 = V.readFromData(data,"w2");
        var t1 = V.readFromData(data,"t1");
        var t2 = V.readFromData(data,"t2");
        if(data.life.asInt()%data.renderInterval.asInt()==0){
            var i = 0;
            for node in V.getPolyhedron(20).vertexes{
                i+=1;
                var colors = [0x0000FF,0x55AAFF,0xFFAAFF,0xFF00FF,0xFFFFFF]as int[];
                var color = colors[i%colors.length];
                var pos = V.scale(V.eulaAng(V.unify(node),t1),200);
                for direction in V.getPolyhedron(8).vertexes{
                    //var phase = 360.0 * data.life.asInt() / data.vChangePeriod.asInt();
                    var vs = 3;//data.v1.asDouble() * V.sinf(phase)*V.sinf(phase) + data.v2.asDouble()*V.cosf(phase)*V.cosf(phase);
                    var v = V.scale(V.eulaAng(V.unify(direction),t2),vs);
                    var p = V.add(pos,V.scale(v,-7.0));
                    FX.LinearOrb.create(world,{
                        "color":color,"colli":false,"lifeLimit":120,"renderSize":6,"size":6,"renderTime":1,"renderInterval":5,"effectiveRadius":300
                    }+V.asData(v,"v")+V.asData(p));
                }
            }
        }
        //M.shout(V.asString(t1));
        return data+V.asData(V.add(w1,t1),"t1")+V.asData(V.add(w2,t2),"t2");
    })
    .regi();
//TODO: more fireworks

static FIREWORKS as FX.FXGenerator[string] = {
    "fish": FISH,
    "comet": COMET,
    "roll1": ROLL1
} as FX.FXGenerator[string];

val spawnFirework as ZenCommand = ZenCommand.create("firework");
    spawnFirework.requiredPermissionLevel = 0;
    spawnFirework.tabCompletionGetters = [
        function(server, sender, pos) {
            return mods.zenutils.StringList.create(["spawn","count","disable","enable","clear"]);
        }  as IGetTabCompletion,
        function(server, sender, pos) {
            return mods.zenutils.StringList.create(FIREWORKS.keys);
        }  as IGetTabCompletion];

    spawnFirework.execute = function(command, server, sender, args) {
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
            //TODO
            if(args.length>0){
                if(args[0]=="disable"){
                    //TODO: Save Data System
                    //The system for the entire save file.
                    //We should also merge the difficulty system into this system
                    //The realization is simply customWorldData in the dim=0 world
                }
                if(args[0]=="enable"){

                }
                if(args[0]=="clear"){
                    //TODO: FXGenerator.clear(world/null)
                }
            }
            player.sendChat("Missing arguments!");
        }
    };
spawnFirework.register();

events.onWorldTick(function(event as crafttweaker.event.WorldTickEvent){
    var world = event.world;
    if(DL<1)return;
    if(world.remote) return;
    if(world.dimension!=0) return;
    //fish
    if(world.random.nextInt(30000)<DCOEF){
        if(FISH.countObjects(world.dimension)<DCOEF)FISH.create(world,{});
    }
    //commet
    if(world.random.nextInt(90000)<DCOEF){
        if(COMET.countObjects(world.dimension)<DCOEF)COMET.create(world,{});
    }
    //roll1
    if(world.random.nextInt(270000)<DCOEF){
        if(ROLL1.countObjects(world.dimension)<1)ROLL1.create(world,{});
    }
});

//TODO: If we've got an "achievement system", we can have [manually spawn 300 firework through command] as an achievement.