#!/usr/bin/perl -w
# trush@yandex.ru
# Run "./netlist-sortbywires2.pl pk11-16.net >pk11-16.wires.txt"
# or "./netlist-sortbywires2.pl pk11-16-ram.net >pk11-16-ram.wires.txt"

$PRINT_PINS=0;

sub magic
{
    my $w = $_[0];
    return $w if $w =~ /^INT\d-/;
    return " $w" if $w eq "GND" or $w =~ /^VBAT/;
    $w =~ s/(\d+)MHZ/${1}000000HZ/g;
    $w =~ s/(\d+)KHZ/${1}000HZ/g;
    my @w = map { sprintf "%08d", $_ } $w =~ /(\d+)/g;
    $w =~s/(\d+)/0000/g;
    return $w . join("",@w);
}

    while(<>)
    {
        s/\r//; # remove MSDOS symbol ^M

#  (net "~AD10-CPU"
#    (node "D3" "5")
#    (node "D1" "61")
#  )
        if(/^\s*\(net \"(\S+)\"/)
        {
            $w=$1;
# printf "$w => %s\n", magic($w);
        }
        if(/^\s*\(node \"(\S+)\" \"(\S+)\"/)
        {
            $chip=$1;
            if($PRINT_PINS)
            {
                $pin=$2;
                push @{$W{$w}}, "$chip.$pin";
            }
            else
            {
                push @{$W{$w}}, $chip;
            }
        }
    }
    @Wkeys = sort {
                      my @a = $a =~ /^([~+-]?)(.*?)?$/;
                      my @b = $b =~ /^([~+-]?)(.*?)?$/;
                      $a[0]="" unless defined $a[0];
                      $b[0]="" unless defined $b[0];

                      $a[1]=""  unless defined $a[1];
                      $b[1]=""  unless defined $b[1];

                      $a[1] = magic($a[1]);
                      $b[1] = magic($b[1]);
                      $a[1].$a[0] cmp $b[1].$b[0]; }
             keys %W;



    foreach $w (@Wkeys)
    {
        $w =~ /^([~+-]?)([A-Z]*)/;
        $prefix = $2;
        #print "$prefix\n";
        if(!exists($PL{$prefix}) || $PL{$prefix} < length($w))
        {
            $PL{$prefix} = length($w);
        }
    }

    foreach $w (@Wkeys)
    {
        undef %u;
        map { ++$u{$_} } @{ $W{$w} };
        @k = sort {
                      my @a = $a =~ /^(.*?)(\d+?)?$/;
                      my @b = $b =~ /^(.*?)(\d+?)?$/;
                      $a[0]="" unless defined $a[0];
                      $b[0]="" unless defined $b[0];
                      $a[1]="0"  unless defined $a[1];
                      $b[1]="0"  unless defined $b[1];
                      $a[1] = sprintf "%05d", $a[1];
                      $b[1] = sprintf "%05d", $b[1];
                      $a[0].$a[1] cmp $b[0].$b[1];

                 } keys %u;
        @s = map { ($u{$_}==1)? $_ : $u{$_}.'x'.$_ } @k;

        $w =~ /^([~+-]?)([A-Z]*)/;
        $sp = " " x ($PL{$2} - length($w));
        $sp .=" " if($w =~ /^\~/);
        printf "[%20s]\t%s\n", $w.$sp, join (" ", @s);
    }
