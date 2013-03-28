package cmd;
import cmd.Proc;
import neko.io.Process;
import haxe.io.Bytes;
import haxe.io.Input;
import haxe.io.Output;

class Proc{
    var process : Process;
    var _stdout : Bytes;
    var _stderr : Bytes;

    public function new(p : Process) this.process = p

    public function pipe(?close=true) {
        if (close) process.close();
        return new Cmd(this);
    }

    public function stdin(bytes : Bytes){
        process.stdin.write(bytes);
        process.stdin.flush();
        return this;
    }
    public function stdout(func : Bytes->Void){
        var tmp = process.stdout.readAll();
        if  (tmp + '' != '') _stdout = tmp;
        func(_stdout);
        return this;
    }
    public function stderr(func : Bytes->Void, redirect = false){
        var tmp = process.stderr.readAll();
        if  (tmp + '' != '') _stderr = tmp;
        func(_stderr);
        if (redirect) {
           _stdout = Bytes.ofString(_stdout.toString() + _stderr.toString());
        }
        return this;
    }
    public function exit(?func : Int->Void){
        if (func != null) func(process.exitCode());
        return this;
    }

}
