package cmd;
import haxe.macro.Expr;
import neko.io.Process;

class MacroCmd {
    static var field_reg = ~/^[a-z][a-z_]+$/;
    static var keyword_reg = {
        var exclude = [ 
                "if",
                "then",
                "else",
                "case",
                "for",
                "continue",
                "trace",
                "switch",
                "while",
                "do",
                "function"
            ];
        var ex_reg  = new Array<String>();
        for (e in exclude) ex_reg.push("(" + e + ")"); 
        var ex_str = ex_reg.join("|");
        new EReg(ex_str, '');
    }

    @:macro public static function build() : Array<Field> {        
        var pos = haxe.macro.Context.currentPos();
        var fields = haxe.macro.Context.getBuildFields();
        var p = new Process("sh", ["-c", "compgen -c"]);
        p.exitCode(); 
        var command_arr = p.stdout.readAll().toString().split("\n");
        p.close();
        var commands = new Hash<String>();
        for (c in command_arr){
            if (! field_reg.match(c)) continue;
            if (c == '') continue;
            if (keyword_reg.match(c)) continue;
            else commands.set(c, c);
        }
        for (c in commands){
            var command = deepCopy(fields[0]);
            switch(command.kind) {
                default: null;
                case FFun(x):
                    switch(x.expr.expr) {
                        default: null;
                        case EBlock(x):
                            switch(x[0].expr) {
                                default: null;
                                case EVars(x): {
                                        //trace(x[0].expr.expr);
                                        x[0].expr.expr = EConst(CString(c));
                                }
                            };
                    }
            }
            command.name = c;
            command.access = [APublic];
            fields.push(command);
        }
        return fields;
    }

    /** 
      deep copy of anything 
     **/ 
    public static function deepCopy<T>( v:T ) : T 
    { 
        if (!Reflect.isObject(v)) return v // simple value
        else if( Std.is( v, Array ) ) // array 
        { 
            var r = Type.createInstance(Type.getClass(v), []); 
            untyped 
            { 
                for( ii in 0...v.length ) 
                    r.push(deepCopy(v[ii])); 
            } 
            return r; 
        } 
        else if( Type.getClass(v) == null ) // anonymous object 
        { 
            var obj : Dynamic = {}; 
            for( ff in Reflect.fields(v) ) 
                Reflect.setField(obj, ff, deepCopy(Reflect.field(v, ff))); 
            return obj; 
        } 
        else // class 
        { 
            var obj = Type.createEmptyInstance(Type.getClass(v)); 
            for( ff in Reflect.fields(v) ) 
                Reflect.setField(obj, ff, deepCopy(Reflect.field(v, ff))); 
            return obj; 
        } 
        return null; 
    } 
}
