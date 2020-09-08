var i,j,k:integer;
inp:file of integer;
out:text;
name:array[1..16]of char;
begin
write('::');readln(name);
reset(inp,name);
rewrite(out,'fnt.mac');
for i:=1 to 256 do get(inp);
for i:=0 to 1290 do
begin
 if (i mod 8)=0 then write(out,'.word');
 write(out,chr(11B),inp^:-6);
 get(inp);
 if ((i mod 8)<7) and (i<>1290) then write(out,',');
 if (i mod 8)=7 then writeln(out);
end;
writeln(out);
close(out);
end.

