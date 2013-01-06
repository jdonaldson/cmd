import cmd.Cmd;
class Main {
    static function main() {
        var c = new Cmd();
        c.ls(['-l']).pipe().grep(["build.hxml"]).stdout(function(x) trace(x));
    }
}



