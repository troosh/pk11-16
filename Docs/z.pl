#!/usr/bin/perl

# ./z.pl VTF.MAC >VTF.TXT

$h=10;
$c=$n=0;
print "\n╔══ 00 ══╗\n║";
while(<>)
{
   foreach (/(\d+)/g)
   {
         next if $h-- > 0; # Skip header (10 words)
         my $v=oct $_;
         for($i=1;$i<256;$i<<=1)
         {
             printf "%s", ($v&$i)? "■" : " ";
         }
         print "║\n║";
         for($i=256;$i<65536;$i<<=1)
         {
             printf "%s", ($v&$i)? "■" : " ";
         }
         print "║\n";
         if (++$n==5)
         {
             print "╚════════╝\n\n";
             exit if ++$c == 256;
             printf "\n╔══ %02X ══╗\n║", $c;
             $n=0;
         }
         else
         {
             print "║";
         }
   }
}
