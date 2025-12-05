# flex -- flexible arrays #

class flex ()
begin fetch update, retrieve, append, delete, size, next, 
            index, top;
      store size : change_size;

      var mem, size;

      proc extend()
      ( var i, m1 := array(mem.size + 10, undefined);
        for i in mem.index do m1[i] := mem[i] od;
        mem := m1
      );

      proc retrieve(i)
      if 0 <= i < size then return(mem[i]) else stop(-1) fi;

      proc update(i, v)
      if 0 <= i < size then return(mem[i] := v) else stop(-1) fi;

      proc append(v)
      ( if size >= mem.size then extend fi;
        mem[size] := v;
        size := size + 1;
        return(v)
      );

      proc delete(n)
      ( if size - n <= 0 then freturn else size := size - n fi );

      proc change_size(n)
      if n < 0 then freturn
      else
         if n >= mem.size then extend fi;
         return(size := n)
      fi;

      proc next(state)
      ( if state = undefined then state := 0 fi;
        if state < size then
           return([mem[state], state + 1])
        else
           freturn
        fi
      );

      proc index() return(interval(0, size - 1, 1));

      proc top()
      if size = 0 then freturn else return(mem[size-1]) fi;

init: mem := array(10, undefined);
      size := 0;
end flex;
