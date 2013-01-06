package cmd;
import sys.System;
import haxe.io.Bytes;
import cmd.Proc;
import neko.io.Process;

//#if !disable_proc_macro @:build(proc.MacroProc.build()) #end 
class Cmd #if !disable_proc_dynamic implements Dynamic<Array<String>->Proc> #end 
{
    function _temp(?args:Array<String>) {
        if (args == null) args = [''];
        var name = 'temp';
        var p = new Process(name, args);
        handleProc(_proc, p);
        return new Proc(p);
    }
    static function handleProc(proc:Proc, p:Process){
        if (proc != null){
            proc.stdout(function(stdout) {
                p.stdin.write(stdout);
                p.stdin.close();
            });
        }
    }
    var _proc:Proc;
    public function new(?proc:Proc){
        if (proc != null) this._proc = proc;
    }
    function resolve(func:String):Array<String>->Proc{
        var which_func = System.which(func);
        if (which_func == null) {
            throw "Command not found: " + func;
            return null;
        }
        return callback(call, {func: func, proc: _proc});
    }
    static function call(
            obj : {func : String, proc : Proc}, 
            args : Array<String>){
        var p = new Process(obj.func,args);
        if (obj.proc != null){
            obj.proc.stdout(function(stdout:Bytes) {
                p.stdin.write(stdout);
                p.stdin.close();
            });
        }
        return new Proc(p);
    }
}
