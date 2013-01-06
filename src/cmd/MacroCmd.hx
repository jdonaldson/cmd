package proc;
import haxe.macro.Expr;
import neko.io.Process;
class MacroCmd {
    static var field_reg = ~/^[a-z][a-z_]+$/;
    static var keyword_reg = ~/(if)|(then)|(else)|(case)|(for)|(continue)|(switch)|(while)|(do)|(function)/;
    public static function deepCopy<T>(o:T):T{
        if (Std.is(o, Array)){
            var o_arr = cast(o, Array<Dynamic>);
            var res = [];
            res = cast(o, Array<Dynamic>).copy();
            for (r in 0...o_arr.length){
                res[r]  = deepCopy(o_arr[r]);
            }
            return cast res;
        } else if (Reflect.isObject(o)){
            var res = {};
            for (f in Reflect.fields(o)){
                Reflect.setField(res,f, deepCopy(Reflect.field(o,f)));
            }
            return cast res;
        } else return o;

    }

    @:macro public static function build() : Array<Field> {        
        var pos = haxe.macro.Context.currentPos();
        var fields = haxe.macro.Context.getBuildFields();
        var p = new Process("sh", ["-c", "compgen -c"]);
        p.exitCode();
        var command_arr = p.stdout.readAll().toString().split("\n");
        var commands = new Hash<String>();
        for (c in command_arr){
            if (! field_reg.match(c)) continue;
            if (keyword_reg.match(c)) continue;
            else commands.set(c,c);
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
                                          case EVars(x): x[0].expr.expr = EConst(CString(c));
                                      };
                         }
            }
            command.name = c;
            command.access = [APublic];
            fields.push(command);
        }
        return fields;
    }
}
