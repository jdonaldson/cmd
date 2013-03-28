Cmd
========

Cmd is a library for working more easily with low level system commands.

To use it, simply create a new Cmd object.  This instance is treated as if it
had methods corresponding to system commands available in the shell.

Simply calling the method "ls" of the Cmd instance will run the bash ls
command in the resulting executable.

```js
import cmd.Cmd;
class Main {
    static function main() {
        var c = new Cmd();
        c.ls(['-l']);
    }
}
```
Handling system calls
---------------------
Cmd uses two different techniques for determining how to handle arbitrary
system commands.

The Cmd class extends Dynamic, meaning that its instances
are all dynamic function fields.  Each method call (e.g. ls()) is handled by
the resolve(func:String) function, which invokes the name of the method (ls)
as the relevant system command.

Cmd also provides a macro for determining which system calls are
available. This macro will execute compgen -c on behalf of the user, and
turn the resulting command completions into static Cmd class field definitions.
These commands are then available through autocompletion, etc.

It is possible to disable the "extends Dynamic" behavior by setting the
compiler flag "-D disable_proc_dynamic".  This will effectively "type check"
the available commands, preventing you from calling a command that doesn't
exist on your computer.  Note that this restriction only exists at compile time,
so if the compiled code is moved to another computer, or the available system
commands change, errors will be thrown.

The other alternative is to disable the macro feature with
"-D disable_proc_macro".  This will make the class behave like it simply
implements Dynamic.

Handling Processes with "Proc"
------------------------------
Cmd also comes with a new way of handling stdin and stdout from processes that
it creates.  These are known as "Procs" and are created from existing processes.
Procs provide a chainable interface, so stdout accepts a function argument
that can handle the output retrieved from the process.

```js
import cmd.Proc;
import neko.io.Process;
class Main {
    static function main() {
        var p = new Process("ls",[]);
        var proc = new Proc(p);
        proc.stdout(function(x) trace(x));
    }
}

```

Since Proc provides a chaining interface, it's possible to chain Procs together
similar to pipe operator in bash.  Proc provides the "pipe()" method, which
produces a Cmd instance:

```js
    var p = new Process("ls",[]);
    var proc = new Proc(p);
    proc.pipe().grep(['test.txt']);
```

Here's an example using ls to list available files, and using grep to
find matches.

```js
    var c = new Cmd();
    c.ls(['-l']).pipe().grep(['test.txt']).stdout(function(x) trace(x));
```

Other Notes:
------------

Proc's stdin method caches the last result, so that it's possible to run
stdout(), and then later to pipe() to a new Cmd.

Proc's stderr method accepts a second "redirect" argument which will copy
stderr to stdin.

There's a simple exit() method that will wait until the proc is finished.
