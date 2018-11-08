#!/usr/bin/perl -w
# trush@yandex.ru

# ./eqn2gal.pl km1556hl8-p1.eqn PAL16L8   P1-5304
#              ^--input_file    ^--device ^--signature

die "Run with arguments or run script 'convert_eqn2gal.sh'!!!\n" unless defined $ARGV[0];

$inputfile = $ARGV[0];
$orig_dev  = $ARGV[1];
$signature = $ARGV[2];


unless (open EQN, "< $inputfile")
{
    warn "Не получилось открыть файл $inputfile\n";
    return;
}
while(<EQN>)
{
 push @H, $_;
 last if /^Equations:/;
}

#/rf16 := rf16 & rf17 +
#         /rf16 & /rf17
#rf16.oe = OE
while(<EQN>)
{
 do {
    foreach $t (/([ior]f?\d+)/g)
    {
       $T{$t} = 1;
    }
    if(/^\/?rf\d+\.oe = OE/)
    {
       s/^(\S+)\.oe =/; $1.E =/;
    }
    elsif(/^\/?o(\d+)\.oe = /)
    {
       $TS{"O$1"} = 1;
       s/^\/?(\S+)\.oe =/$1.E =/;
    }
    elsif(/^\/?rf\d+ :=/)
    {
       s/^(\/?rf\d+) :=/$1.R =/;
    }

    s/ =(\s+)$/ = VCC\n/;
 } while(0);
 push @B, uc($_);
}


close EQN;

print "GAL16V8                 ; Target device, original is $orig_dev\n";
printf "%-23s ; Original equations get from\n\n\n", $inputfile;


foreach (keys %T)
{
 /^\S+?(\d+)$/;
 $pins[$1]=uc($_);
}
$pins[10]="GND";
$pins[20]="VCC";
if($orig_dev ne "PAL16L8")
{
  $pins[1]="Clock";
  $pins[11]="OE";
}
#Clock i2    i3    i4    i5    i6    i7    i8    i9   GND
#/OE   o12   o13   rf14  rf15  rf16  rf17  o18   o19  VCC
for($i=1; $i<=20; $i++)
{
 printf "%-8s", (defined $pins[$i])? $pins[$i] : "NC";
 printf "%s", ($i==10 or $i==20)? "\n" : " ";
}

print "\n\n";
foreach $l (@H)
{
 print "; $l";
}


foreach (@B)
{
 if(/^\/?(O\d+) = /)
 {
   s/^(\/?)(O\d+) = /$1$2.T = / if exists $TS{$1};
 }
 print "$_";
}

print "DESCRIPTION\n\n";
print "TODO: signature: $signature\n";
