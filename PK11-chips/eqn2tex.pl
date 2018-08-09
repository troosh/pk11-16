#!/usr/bin/perl -w

use File::Basename;
#use Data::Dumper;

$FEEDBACKS_DISPLAY=1; # Отображать внутрение связи в ПЛМ
$ENABLE_P_PARTS=1;    # Разрешить прошивки P1-P14?..
$ENABLE_V_PARTS=1;    # Разрешить прошивки V1-VC?..

@lt = localtime(time);
$timestamp = sprintf "%04d%02d%02d", 1900+$lt[5], 1+$lt[4], 1+$lt[3];
open TEX, "> pk11logic-v${timestamp}.tex" || die "Can't open file pk11logic-v${timestamp}.tex\n";
print TEX '\documentclass[a4paper,russian]{report}
\usepackage[a4paper,margin=1cm,bottom=2cm]{geometry}
\setcounter{secnumdepth}{3}\setcounter{tocdepth}{3}
\usepackage[utf8]{inputenc}
\usepackage[russian]{babel}
\usepackage{indentfirst}
\usepackage{paralist}
\usepackage{titlesec}
\usepackage{tabularx}
 \makeatletter
 \let\tx@\TX@endtabularx
 \def\restoretx{\let\TX@endtabularx\tx@}
 \makeatother
\usepackage{ltablex}
 \newcolumntype{L}{>{\raggedright\arraybackslash}X}
 \newcolumntype{C}{>{\centering\arraybackslash}X}
 \newcolumntype{R}{>{\raggedleft\arraybackslash}X}
\usepackage{refcount}
\usepackage{amsmath}
\usepackage{amsfonts}
\usepackage[colorlinks=true,linkcolor=blue]{hyperref}
 \usepackage{underscore}
\usepackage{makecell}

\sloppy
\emergencystretch=10em
\hyphenpenalty=10000
\exhyphenpenalty=10000

\titleformat{\chapter}[display]
 {\normalfont\bfseries}{}{0pt}{\Large}';

print TEX "\\begin{document}\n
Индекс у переменных -- номер вывода в корпусе соответствующей микросхемы!   (v${timestamp})

Если переменная начинается с \\emph{I}... то вывод используется только как вход,
если начинается с \\emph{O}... -- то это выход (но может быть использован также
и как вход в логических выражениях), если же начинается с \\emph{RF}... --
то это выход с защелкой (который также может быть использован и как вход).

Логические выражения, использующие вход \\emph{OE} микросхем, удалены (за исключение
микросхемы \\emph{VB}, где данный вход реально используется, т.е. не посажен на землю). \\\\\n";

$Regs_used=0; # Число задействованных регистов в ПЛМ-ках
$Zbuf_used=0; # Число управлеяемых Z буферов
$Pads_used=0; # Число внешних соединений
$Pads_input=0;
$Pads_output=0;


open INFO, "> graph.info.txt" || die "Can't open file graph.info.txt\n";
open GRAPH, "> graph.gv" || die "Can't open file graph.gv\n";

print GRAPH "digraph pk11 {\nrankdir=LR;\nranksep=\"4 equally\";\nnode [shape=record;fontsize=24];\n";


$nl=3;
sub check_r
{
        if(defined $r and !(substr($r,-3) eq ".oe" and ($v eq "vcc" or ($chip ne "VB" and $v eq "OE"))))
        {
             $r = uc($r);
             $v = uc($v);

             # Число задействованных регистров
             ++$Regs_used if $r =~/RF/;
             # Запоминаем какие выходы были использованы
             $r =~ /(\w+\d+)(.OE)?/; my $rcon=$1;  $OUTPUTS{$rcon}=1; ++$Zbuf_used if defined $2;
             foreach ($v =~ /([OR]F?\d+)/g) { $FEEDBACKS{"$firmware:$_:e->$firmware:$rcon:w"}=1 }; # Запоминаем какие выходы были использованы как входы (обраные связи)


             $r =~ s/((\S+?)(\d+))/$2_{$3}/;
#             if ($r =~/\.oe$/i) # Инверсия входов OE -- теперь вроде не требуется
#             {
#                 $n = ($n eq '/')? ' ' : '/';
#             }
             foreach ($v =~ /(I\d+)/g) { $INPUTS{$_}=1 }; # Запоминаем какие входы были использованы

             $v =~ s/((\S+?)(\d+))/$2_{$3}/g;
             $v =~ s/\/(\S+)/\\overline{$1}/g;
             $v =~ s/ [\*&] /\ \\cdotp /g;
             if($n eq '/')
             {
                 if( $v eq "VCC")
                 {
                     $v = "0"
                 }
                 else
                 {
#                     $v =~ s/ \+ /\ + } \\\\\n\t& & \\overline{/g;
#                     $v .= "}";
#                     $v = "\\overline{" . $v;
                      $r = "\\overline{" . $r . '}';
                      $v =~ s/ \+ /\ + \\\\\n\t& & /g;
                 }
             }
             else
             {
                 if( $v eq "VCC")
                 {
                     $v = "1"
                 }
                 else
                 {
                     $v =~ s/ \+ /\ + \\\\\n\t& & /g;
                 }
             }
            $nl += 1 + ($v =~ s/\n/\n/g);
            if($nl >= 48)
            {
               $nl=0;
               print TEX " \\end{eqnarray*}\n \\begin{eqnarray*}\n";
            }
            printf TEX "    $r & $t & $v \\\\%s\n", ($r =~/\.oe}?$/i)? " \\\\": "";

        }
        undef $r;
}

@Vx_jeds=qw(PAL16R4/V1/3a18d7ec.jed
            PAL16R4/V2/478ed276.jed
            PAL16R6/V3/c29d7927.jed
            PAL16R4/V4/379daf18.jed
            PLS100/V5/9ae37ebb.jed
            PAL16L8/V6/50e71a2b.jed
            PLS100/V7/3e7f5dc3.jed
            PAL16R6/V8/e6489faf.jed
            PAL16R4/V9/07713384.jed
            PLS100/VA/5483badd.jed
            PAL16R4/VB/42f88cff.jed
            PAL16L8/VC/aff8d143.jed);
# Забракованные мной прошивки
# PAL16R4/V9/562ab1a0.jed - в счетчике два младших разряда одинаково себя ведут (считает в два раза быстрее)
# PAL16R4/V4/661773d7.jed - делит странно как-то на 6, а вот в 379daf18.jed деление на 10 (хотя по мне на 9 лучше было бы)

@Px_jeds=qw(PAL16L8/P1/5304637b.jed
            PAL16L8/P2/1f908a8a.jed
            PLS100/P3/1b53cec4.jed
            PAL16L8/P4/abafa288.jed
            PAL16L8/P5/5bae8d8b.jed
            PAL16L8/P10/2ca7bbc6.jed
            PAL16R4/P11/301cce3c.jed
            PAL16L8/P12/2f065c7a.jed
            PAL16L8/P13/29dab5f9.jed
            PAL16R6/P14/7a7dc71e.jed);

@JEDFILES=();
@JEDFILES=(@JEDFILES, @Vx_jeds) if $ENABLE_V_PARTS;
@JEDFILES=(@JEDFILES, @Px_jeds) if $ENABLE_P_PARTS;

$chip_num=0;
for $jedfile (@JEDFILES)
{
#printf "\n\n[[$jedfile]] => [[%s]]\n\n", readlink($jedfile);
$chip = dirname($jedfile) . '/'. basename(readlink($jedfile), qw(.jed .JED));
open FILE, "< $chip.eqn" || die "Can't open file $chip.eqn\n";
#open RTL, "> $chip.v" || die "Can't open file $chip.v\n";

$chip_text = $chip . "  (" . basename($jedfile). ")";
$chip_text =~ s/([_])/\\$1/g;
@alt_dumps = glob(dirname($jedfile)."/[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f].jed");
printf TEX "\n%d) Микросхема: \\emph{$chip_text}, альтернативных дампов: %s\n\\nopagebreak\\begin{eqnarray*}\n", ++$chip_num, $#alt_dumps? $#alt_dumps: "\\emph{нет!}";

$firmware = basename(dirname($jedfile));

$fw=$firmware; ####################3
#next if $fw ne "V1" and $fw ne "V2" and $fw ne "V3" and $fw ne "V4" and $fw ne "V8" and $fw ne "V9";
#next if $fw ne "V3" and $fw ne "V4" and $fw ne "V9";

$FWused{$firmware}=1;
$type=dirname(dirname($jedfile));
print GRAPH "# <<< $firmware >>>\n";
undef %OUTPUTS;
undef %INPUTS;
undef %FEEDBACKS;

while(<FILE>)
{

#/o12 = i1 * /i7 * i9^M
#    + /i1 * i7 * i9^M
#    + i2 * i18 * i17 * /i9^M
#o12.oe = vcc^M

#/o12 = i1 & /i7 & i9 +
#       /i1 & i7 & i9 +
#       i2 & /i9 & i17 & i18
#o12.oe = vcc

    s/\r//;
    if(/^(\/)?(\S+) (:?=) (.+)$/)
    {
        check_r();
        $n = (defined $1)? $1 : ' ';
        $r = $2;
        $t = $3;
        $v = $4;
    }
    elsif(/^(\/)?(\S+) (:?=) $/)  # Делаем отдельным случаем обработку пустой формулы: очему-то jedutil вместо "O17 = vcc" выдаёт "O17 = "
    {
        check_r();
        $n = (defined $1)? $1 : ' ';
        $r = $2;
        $t = $3;
        $v = "vcc";
    }
    elsif(/^\s+( \+? .+)$/)
    {
        $v .= $1;
    }
}
check_r() if defined $r;
$nl=0;
print TEX " \\end{eqnarray*}\n\\pagebreak[1]\n\n";

undef @INPS;
undef @OUTS;
$FW{$firmware}{1}="CLK" if $type =~ /^PAL16R/;
$FW{$firmware}{11}="OE" if $type =~ /^PAL16R/;
$FW{$firmware}{19}="OE" if $type =~ /^PLS100/;
print GRAPH "\n\n# Firmware: $firmware\n# Inputs:\n";
foreach (sort { my @a=$a=~/^(\w+)(\d+)/; my @b=$b=~/^(\w+)(\d+)/; $a[0] cmp $b[0] || $a[1] <=> $b[1] } keys %INPUTS)
{
    print GRAPH "# $_\n";
    push @INPS, "<$_>$_";
    /\w+?(\d+)$/;
    $FW{$firmware}{$1}=$_;
}
print GRAPH "# Outputs:\n";
foreach (sort { my @a=$a=~/^(\w+)(\d+)/; my @b=$b=~/^(\w+)(\d+)/; $a[0] cmp $b[0] || $a[1] <=> $b[1] } keys %OUTPUTS)
{
    print GRAPH "# $_\n";
    push @OUTS, "<$_>$_";
    /\w+?(\d+)$/;
#print GRAPH "#>>>> \$FW\{$firmware\}\{$1\} <= $_\n";
    $FW{$firmware}{$1}=$_;
}



# V4 [label="{ <CLK>CLK | <i2>i2 | <i3>i3 | i9 | /OE } | { V4 \n PAL16R4 } | { <f12>f12 | <f18>f18 | <f19>f19 }"];
print GRAPH "$firmware [label=\"{ { ";
print GRAPH "<CLK>CLK | " if $type =~ /^PAL16R/;
print GRAPH join(" | ", @INPS);
print GRAPH " | <OE>OE" if $firmware eq "VB"; #if $type =~ /^PAL16R/ or $type =~ /^PLS100/;
print GRAPH "} | { $firmware \\n $type } | { ";
print GRAPH join(" | ", @OUTS);
print GRAPH " } }\"];\n";

print GRAPH "# Feedbacks:\n";
if($FEEDBACKS_DISPLAY){
foreach (sort keys %FEEDBACKS)
{
# P14:RF17:e->P14:RF18:w
    /^(\S+:\S+):\w+->(\S+:(\w+?)\d+):\w+$/;
    if($1 ne $2)
    {
        printf GRAPH "$_ [color=%s];\n", ($3 eq "RF")? "green":"red";
    }
    else
    {
        printf GRAPH "$_ [color=%s];\n", ($3 eq "RF")? "olivedrab4":"orange4";
    }
}
}
else
{
 print GRAPH "#DISABLED!\n";
}

print GRAPH "# --\n\n";

close FILE;
}

print TEX "\\end{document}\n\n";


# Hot fixed
$FW{V1}{3}="I2"; # В прошивке не используется, но сигнал заведён!

    open NETLIST, "< pk11-16.net" || die "Can't open file pk11-16.net\n";
    while(<NETLIST>)
    {
        s/\r//; # remove MSDOS symbol ^M

#  (compInst "D57"
#    (compRef "KM1556HP4_1")
#    (originalName "KM1556HP4")
#    (compValue "V4")
#    (patternName "N020")
#  )
        if(/^\s*\(compInst \"(\S+)\"/)
        {
            $comp=$1;
            next;
        }
        if(/^\s*\(compValue \"(\S+)\"/)
        {
            $comp_val=$1;
#print INFO "\n\n# $comp_val -> $comp !!!\n" if exists $FWused{$comp_val};
            $N2V{$comp} = $comp_val if exists $FWused{$comp_val};
            next;
        }

#  (net "~AD10-CPU"
#    (node "D3" "5")
#    (node "D1" "61")
#  )
        if(/^\s*\(net \"(\S+)\"/)
        {
            $w=$1;
            if($w eq "GND" || $w =~ /^\+5V/ || $w =~ /^VBAT/ || $w eq "+12V" || $w eq "-12V" || $w eq "NET00062" || $w eq "NET00064")
            {
                 $ign_mode=1;
                 next;
            }
            $ign_mode=0;
#print INFO "$w\n";
            $print_w=1;
            next;
        }
        if(!$ign_mode and /^\s*\(node \"(\S+)\" \"(\S+)\"/)
        {
#print INFO "$_";
            $chip=$1;
            $pin=$2;
            if(exists $N2V{$chip})
            {
              $fw = $N2V{$chip};
#next if $fw ne "V1" and $fw ne "V2" and $fw ne "V3" and $fw ne "V4" and $fw ne "V8" and $fw ne "V9";
#next if $fw ne "V3" and $fw ne "V4" and $fw ne "V9";
#next unless $fw =~"/^(V[123489B])$/";
              print INFO "$w:\n" if $print_w;
              $print_w=0;
#print INFO "$_";
#printf INFO "\$FW{$fw}{$pin} = %s\n", $FW{$fw}{$pin};
                printf INFO "  $fw:%s\n",   $FW{$fw}{$pin};
                push @{$W{$w}}, "$fw:".$FW{$fw}{$pin};
                $WP{$w}=1;
                next;
            }
            else
            {
                print INFO "$w:\n" if $print_w;
                $print_w=0;
                print INFO "  $chip:$pin\n";
                push @{$W{$w}}, "$chip:$pin";
                next;
            }
        }
    }

foreach $w (sort keys %WP)
{
    print GRAPH "# $w: ", join(" ", @{$W{$w}}), "\n";
    undef @INPS;
    undef @OUTS;
    undef @LINKS;
    foreach $o (@{$W{$w}})
    {
        next unless $o =~ /^(V[1-9A-C]|P\d[0-4]?):(O\d+|RF\d+)$/;
        push @OUTS, $o;
        foreach $i (@{$W{$w}})
        {
            next unless $i =~ /^(V[1-9A-C]|P\d[0-4]?):(I\d+|CLK|OE)$/;
            push @LINKS,"$o:e->$i:w\n";
        }
    }

    foreach $i (@{$W{$w}})
    {
        next unless $i =~ /^(V[1-9A-C]|P\d[0-4]?):(I\d+|CLK|OE)$/;
        push @INPS, $i;
    }

    print GRAPH "# $#INPS $#OUTS $#{$W{$w}}\n";
    if (($#INPS>=0 || $#OUTS>=0) &&
        1 + $#INPS + $#OUTS != $#{$W{$w}})  # Если список состоит не только из выводов ПЛМ-ок
    {
        my $ww = $w;
        $ww =~ s/[-\/~\&]/_/g; # Минусы и другие символы не нравяться dot-у
        print GRAPH "$ww [label=\"{ $w }\"];\n";
        ++$Pads_used;
        foreach $i (@INPS)
        {
            print GRAPH "$ww:e->$i:w [color=darkgoldenrod4]\n";
        }
        foreach $o (@OUTS)
        {
            print GRAPH "$o:e->$ww:w [color=blue4]\n";
        }
        ++$Pads_input  if($#OUTS==-1);
        ++$Pads_output if($#INPS==-1);
    }
    else
    {
        foreach (@LINKS)
        {
            print GRAPH "$_\n";
        }
    }
}

#print GRAPH "NET00060->NET00059\n"; # Хак под кварц

# Добавление мультплексирования на резисторах
# Hints
if (111111111) {

# ИЛИ на ДРЛ рядом с CPU  -- но здесь бестолку...
#print GRAPH "OR2 [label=\"{ { <R>R | <K>K } | { OR\\nR10/VD1 } | { <Q>Q } }\"];\n";
#print GRAPH "_SYNC:e->OR2:A:w\n";
#print GRAPH "DIN:e->OR2:R:w\n";
#print GRAPH "OR2:Q:e->NET00056:w\n";


print GRAPH "_DOUT\n";

if($ENABLE_V_PARTS) {
print GRAPH "subgraph cluster_3 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";

print GRAPH "subgraph cluster_18 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
print GRAPH "PF_VN0\n";
print GRAPH "PF_VN1\n";
print GRAPH "PF_PB\n";
print GRAPH "}\n";


print GRAPH "subgraph cluster_23 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
 print GRAPH "  VU1_Y1\n";
 print GRAPH "  VU1_Y2\n";
print GRAPH "V1\n";
print GRAPH "V2\n";
print GRAPH "_MA_LO\n";
print GRAPH "_MA_HI\n";
  print GRAPH "  VU1_Y3\n";
print GRAPH "V6\n";
print GRAPH "_VRF_WR\n";
print GRAPH "X0_8MHZ\n";
print GRAPH "_X1_4MHZ\n";
print GRAPH "_X2_2MHZ\n";
print GRAPH "_X3_1MHZ\n";
print GRAPH "_X4_500KHZ\n";
print GRAPH "_X5_250KHZ\n";
print GRAPH "_RAS1\n";
print GRAPH "_RAS2\n";
print GRAPH "_CWR0\n";
print GRAPH "_CWR1\n";
print GRAPH "_RAS0\n";
print GRAPH "_RAS3\n";
print GRAPH "MA0\n";
print GRAPH "_CAS\n";
print GRAPH "_RAM_RD\n";
print GRAPH "MMPDIS\n";
print GRAPH "_RAM_SEL\n" unless $ENABLE_P_PARTS;
print GRAPH "A01\n" unless $ENABLE_P_PARTS;
print GRAPH "_DIN\n" unless $ENABLE_P_PARTS;
print GRAPH "_RPLY\n";
print GRAPH "NET00060\n";
print GRAPH "NET00059\n";
print GRAPH "NET00061\n";


if(1){
    # ИЛИ на ДРЛ рядом с V2/V3
    print GRAPH "OR1 [label=\"{ { <R>R | <A>A } | { OR\\nR24/VD13 } | { <Q>Q } }\"];\n";
    print GRAPH "V3:RF18:e->OR1:A:w\n";
    print GRAPH "V3:O19:e->OR1:R:w\n";
    print GRAPH "OR1:Q:e->V2:I3:w\n";
#    print GRAPH "NET00062\n"; # Удалить бы вообще - фантом из добавления OR1
}

print GRAPH "VSYNC\n";
print GRAPH "V3\n";



print GRAPH "\n";
print GRAPH "\n";
print GRAPH "\n";
print GRAPH "\n";
print GRAPH "\n";
print GRAPH "}\n";


#print GRAPH "VSYNC\n";

  print GRAPH "_X2_2MHZ:e->R43:w;  R43:e->VA0;\n";
  print GRAPH "_X3_1MHZ:e->R73:w;  R73:e->VA1;\n";
  print GRAPH "_X4_500KHZ:e->R36:w;R36:e->VA2;\n";
  print GRAPH "_X5_250KHZ:e->R37:w;R37:e->VA3;\n";



print GRAPH "subgraph cluster_7 {rank=\"min\";rankdir=TB;color=blue;fontsize=24;label=\"Color LUT address generator\"\n";
  print GRAPH " subgraph cluster_25{rank=\"min\";rankdir=TB;color=blue;fontsize=24;label=MUX3\n";
  print GRAPH " VA0\n";
  print GRAPH " VA1\n";
  print GRAPH " VA2\n";
  print GRAPH " VA3\n";
  print GRAPH " }\n";
# print GRAPH "R43 [height=0.25]\n";
# print GRAPH "R73 [height=0.25]\n";
# print GRAPH "R36 [height=0.25]\n";
# print GRAPH "R37 [height=0.25]\n";
  print GRAPH "subgraph cluster_2 {rank=\"min\";rankdir=TB;color=blue;fontsize=24;label=MUX3\n";
  print GRAPH "R43 [label=\"{ R43 }\" height=0.25];\n";
  print GRAPH "R73 [label=\"{ R73 }\" height=0.25];\n";
  print GRAPH "R36 [label=\"{ R36 }\" height=0.25];\n";
  print GRAPH "R37 [label=\"{ R37 }\" height=0.25];\n";
  print GRAPH "}\n";


print GRAPH "subgraph cluster_17 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
print GRAPH "PF_PN0\n";
print GRAPH "PF_PN1\n";
print GRAPH "}\n";

print GRAPH "V9\n";
print GRAPH "VB\n";
  print GRAPH "subgraph cluster_11 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
  print GRAPH "CA0\n";
  print GRAPH "CA1\n";
  print GRAPH "CA2\n";
  print GRAPH "CA3\n";
  print GRAPH "CA8\n";
  print GRAPH "CA9\n";
  print GRAPH "CA4\n";
  print GRAPH "CA5\n";
  print GRAPH "CA6\n";
  print GRAPH "CA7\n";
  print GRAPH "}\n";
print GRAPH "VC\n";
print GRAPH "NET00063\n";
  print GRAPH "subgraph cluster_12 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
  print GRAPH "VD0\n";
  print GRAPH "VD1\n";
  print GRAPH "VD2\n";
  print GRAPH "VD3\n";
  print GRAPH "VD4\n";
  print GRAPH "VD5\n";
  print GRAPH "VD6\n";
  print GRAPH "VD7\n";
  print GRAPH "}\n";
  print GRAPH "subgraph cluster_1 {rank=\"min\";rankdir=TB;color=blue;fontsize=24;label=MUX2\n";
  print GRAPH "R2  [label=\"{ R2  }\" height=0.25];\n";
  print GRAPH "R11 [label=\"{ R11 }\" height=0.25];\n";
  print GRAPH "R1  [label=\"{ R1  }\" height=0.25];\n";
  print GRAPH "R8  [label=\"{ R8  }\" height=0.25];\n";
  print GRAPH "}\n";
  print GRAPH "VD4:e->R2:w;   R2:e->CA4:w;\n";
  print GRAPH "VD5:e->R11:w; R11:e->CA5:w;\n";
  print GRAPH "VD6:e->R1:w;   R1:e->CA6:w;\n";
  print GRAPH "VD7:e->R8:w;   R8:e->CA7:w;\n";


#    print GRAPH "  subgraph cluster_30 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
#    print GRAPH "  }\n";



print GRAPH "  }\n";

  print GRAPH "  subgraph cluster_15 {rank=\"min\";rankdir=TB;color=blue;fontsize=24;label=\"Video lines counter\"\n";
  print GRAPH "  V8\n";
  print GRAPH "  MD10\n";
  print GRAPH "  MD11\n";
  print GRAPH "  MD12\n";
  print GRAPH "  MD13\n";
  print GRAPH "  MD14\n";
  print GRAPH "  MD15\n";
  print GRAPH "  }\n";


  print GRAPH "  subgraph cluster_8 {rank=\"min\";rankdir=TB;color=blue;fontsize=24;label=\"Microcode Memory\"\n";


print GRAPH "_DAC_EN\n";
  print GRAPH "  V7\n";
  print GRAPH "  _VRF2CLUT_OE\n";
  print GRAPH "  SQ_S1\n";
  print GRAPH "  SQ_S0\n";
  print GRAPH "  _SQ_ZA\n";
  print GRAPH "  _SQ_FE\n";
  print GRAPH "  SQ_PUP_CI\n";
  print GRAPH "  _VPTRLL\n";
  print GRAPH "  _VPTRHL\n";
  print GRAPH "  }\n";


print GRAPH "}\n";



print GRAPH "subgraph cluster_6 {rank=\"min\";rankdir=TB;color=blue;fontsize=24;label=\"DRAM write enables generator\"\n";
print GRAPH "V4\n";
print GRAPH "V5\n";
print GRAPH "_WE_00_01\n";
print GRAPH "_WE_02_03\n";
print GRAPH "_WE_04_05\n";
print GRAPH "_WE_06_07\n";
print GRAPH "_WE_08_09\n";
print GRAPH "_WE_10_11\n";
print GRAPH "_WE_12_13\n";
print GRAPH "_WE_14_15\n";
print GRAPH "subgraph cluster_4 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
print GRAPH "AD00\n";
print GRAPH "AD01\n";
print GRAPH "AD02\n";
print GRAPH "AD03\n";
print GRAPH "AD04\n";
print GRAPH "AD05\n";
print GRAPH "AD06\n";
print GRAPH "AD07\n";
print GRAPH "}\n";
print GRAPH "subgraph cluster_35 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
print GRAPH "A00\n";
print GRAPH "_WTBT\n";
print GRAPH "}\n";

print GRAPH "subgraph cluster_5 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
print GRAPH "AD08\n";
print GRAPH "AD09\n";
print GRAPH "AD10\n";
print GRAPH "AD11\n";
print GRAPH "AD12\n";
print GRAPH "AD13\n";
print GRAPH "AD14\n";
print GRAPH "AD15\n";
print GRAPH "}\n";



print GRAPH "}\n";





}

if($ENABLE_P_PARTS) {
print GRAPH "subgraph cluster_9 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
print GRAPH "NET00002\n";
print GRAPH "NET00004\n";
print GRAPH "NET00005\n";
print GRAPH "NET00008\n";
print GRAPH "NET00009\n";
print GRAPH "NET00011\n";
print GRAPH "_MWD\n";
print GRAPH "DIR\n";
print GRAPH "HD_DRUN\n";
print GRAPH "HD_WRCLK\n";
print GRAPH "HD_DRDY\n";
print GRAPH "HD_DIR\n";
print GRAPH "HD_WRG\n";
print GRAPH "HD_WRD\n";
print GRAPH "FL_DW\n";
print GRAPH "FL_WRCLK\n";
print GRAPH "FL_RDD\n";
print GRAPH "FL_PS0\n";
print GRAPH "FL_PS1\n";
print GRAPH "FL_WE\n";
print GRAPH "WG\n";
print GRAPH "RDY\n";
print GRAPH "LST_DIR\n";
print GRAPH "USEL\n";
print GRAPH "P13\n";
print GRAPH "P14\n";

print GRAPH "P12\n";
print GRAPH "F1SEL\n";
print GRAPH "HN2\n";
print GRAPH "FL_IDX\n";
print GRAPH "F0SEL\n";
print GRAPH "STEP\n";
print GRAPH "WP_TS\n";
print GRAPH "FLT_TRK0\n";
print GRAPH "HN0\n";
print GRAPH "HN1\n";
print GRAPH "WP\n";
print GRAPH "_IND\n";
print GRAPH "TR000\n";
print GRAPH "FR_STP\n";
print GRAPH "HD_STEP\n";
print GRAPH "_RW__SEEK\n";

print GRAPH "P11\n";
print GRAPH "NET00012\n";
print GRAPH "NET00001\n";
print GRAPH "NET00016\n";
print GRAPH "HDBUFA07\n";
print GRAPH "HDBUFA08\n";
print GRAPH "HDBUFA09\n";
print GRAPH "HDBUFA10\n";
print GRAPH "HD_BDRQ\n";
print GRAPH "RUN\n";


print GRAPH "P10\n";
print GRAPH "NET00017\n";
print GRAPH "NET00019\n";
print GRAPH "_FL_RD\n";
print GRAPH "_FL_WR\n";
print GRAPH "_CS_HD\n";
print GRAPH "_HDBUFCS\n";
print GRAPH "_FL_DACK\n";
print GRAPH "_CS_FL\n";


print GRAPH "_HD_BCS\n";
print GRAPH "\n";
print GRAPH "\n";
print GRAPH "\n";
print GRAPH "\n";
print GRAPH "\n";

if($ENABLE_P_PARTS) {
print GRAPH "subgraph cluster_10 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
print GRAPH "DB0\n";
print GRAPH "DB1\n";
print GRAPH "DB2\n";
print GRAPH "DB3\n";
print GRAPH "DB4\n";
#print GRAPH "DB5\n";
#print GRAPH "DB6\n";
#print GRAPH "DB7\n";
print GRAPH "}\n";
}


print GRAPH "}\n";
}







if($ENABLE_V_PARTS) {
print GRAPH "subgraph cluster_16 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
print GRAPH "MMWM2B\n";
print GRAPH "MMWM4B\n";
    print GRAPH " subgraph cluster_19 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
    print GRAPH " PF_VD0\n";
    print GRAPH " PF_VD1\n";
    print GRAPH " }\n";
print GRAPH "VA\n";
print GRAPH "_VRF_RD_LO\n";
print GRAPH "_VRF_RD_HI\n";
print GRAPH "_VRF_A0\n";
print GRAPH "}\n";

print GRAPH "subgraph cluster_20 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
print GRAPH "_RAS0\n";
print GRAPH "_RAS3\n";
print GRAPH "}\n";

print GRAPH "subgraph cluster_21 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
print GRAPH "_RAS1\n";
print GRAPH "_RAS2\n";
print GRAPH "}\n";
}


if($ENABLE_P_PARTS) {

print GRAPH "_RAM_SEL\n" unless $ENABLE_V_PARTS;

print GRAPH "subgraph cluster_22 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
print GRAPH "A01\n";
print GRAPH "A02\n";
print GRAPH "A03\n";
print GRAPH "A04\n";
print GRAPH "A05\n";
print GRAPH "}\n";


print GRAPH "subgraph cluster_40 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
print GRAPH "_DIN\n";
print GRAPH " _SYNC\n";
print GRAPH " _SEL\n";
print GRAPH " P1\n";
print GRAPH " MMBANK\n";
print GRAPH " A12M__A12PG7\n";
print GRAPH " A13M__A12PG7\n";
print GRAPH " subgraph cluster_41 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
print GRAPH " A12\n";
print GRAPH " A13\n";
print GRAPH " A14\n";
print GRAPH " A15\n";
print GRAPH " }\n";
print GRAPH " P3\n";
print GRAPH " subgraph cluster_42 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
print GRAPH " A06\n";
print GRAPH " A07\n";
print GRAPH " A08\n";
print GRAPH " A09\n";
print GRAPH " A10\n";
print GRAPH " A11\n";
print GRAPH " }\n";
print GRAPH " subgraph cluster_43 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
print GRAPH " MMBA12\n";
print GRAPH " MMBA13\n";
print GRAPH " MMBA14\n";
print GRAPH " MMBA15\n";
print GRAPH " MMBA16\n";
print GRAPH " MMBA17\n";
print GRAPH " MMBA18\n";
print GRAPH " MMBA19\n";
print GRAPH " MMBA20\n";
print GRAPH " MMBA21\n";
print GRAPH " }\n";
print GRAPH " subgraph cluster_44 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
print GRAPH " PHA14__O1612XX\n";
print GRAPH " PHA15__O1614XX\n";
print GRAPH " PHA16__O1611XX\n";
print GRAPH " PHA17__O1610XX\n";
print GRAPH " PHA18__O1615XX\n";
print GRAPH " PHA19__O1613XX\n";
print GRAPH " PHA20__O161XXX\n";
print GRAPH " PHA21_IOHWH\n";
print GRAPH " }\n";
print GRAPH " P2\n";
print GRAPH " subgraph cluster_45 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
print GRAPH " IOINT\n";
print GRAPH " IHLT\n";
print GRAPH " }\n";
print GRAPH " subgraph cluster_46 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
print GRAPH " EF0\n";
print GRAPH " EF1\n";
print GRAPH " }\n";
print GRAPH " P2_15\n";
print GRAPH " _HALT\n";

print GRAPH " subgraph cluster_47 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
print GRAPH " _IOW\n";
print GRAPH " _IOR\n";
print GRAPH " }\n";

print GRAPH "subgraph cluster_0 {rank=\"min\";rankdir=TB;color=blue;fontsize=24;label=MUX1\n";
print GRAPH "R31 [label=\"{ R31 }\" height=0.25];\n";
print GRAPH "R30 [label=\"{ R30 }\" height=0.25];\n";
print GRAPH "R9  [label=\"{ R9  }\" height=0.25];\n";
print GRAPH "R29 [label=\"{ R29 }\" height=0.25];\n";
print GRAPH "}\n";
print GRAPH "A01:e->R31:w; R31:e->MMRA1:w;\n";
print GRAPH "A02:e->R30:w; R30:e->MMRA2:w;\n";
print GRAPH "A03:e->R9:w;   R9:e->MMRA3:w;\n";
print GRAPH "A04:e->R29:w; R29:e->MMRA4:w;\n";

print GRAPH "subgraph cluster_14 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
print GRAPH "MMRA1\n";
print GRAPH "MMRA2\n";
print GRAPH "MMRA3\n";
print GRAPH "MMRA4\n";
print GRAPH "}\n";


print GRAPH " P5\n";
print GRAPH " subgraph cluster_48 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
print GRAPH " PAFD\n";
print GRAPH " PSEL\n";
print GRAPH " PRST\n";
print GRAPH " PSTB\n";
print GRAPH " }\n";
print GRAPH " subgraph cluster_49 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
print GRAPH " _LPT_PAFD\n";
print GRAPH " _LPT_PSEL\n";
print GRAPH " _LPT_PRST\n";
print GRAPH " _LPT_PSTB\n";
print GRAPH " NET00057\n"; # LPT.BUF_OE
print GRAPH " }\n";
#_LPT_ERR
#LPT_PE
#_LPT_ACK
#LPT_BUS:
print GRAPH " subgraph cluster_50 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
print GRAPH " _CS_VV51\n";
print GRAPH " _CS_VV55\n";
print GRAPH " _CS_VV79\n";
print GRAPH " }\n";

print GRAPH " P4\n";
print GRAPH " subgraph cluster_51 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
print GRAPH " _CS_VN59\n";
print GRAPH " _CS_VI53L\n";
print GRAPH " _CS_VI53D\n";
print GRAPH " }\n";
print GRAPH " subgraph cluster_52 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
print GRAPH " RXD_INV\n"; # TX ���� �����������
print GRAPH " NET00027\n";
print GRAPH " NET00028\n";
print GRAPH " }\n";
print GRAPH " subgraph cluster_53 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
print GRAPH " NET00032\n";
print GRAPH " NET00013\n";
print GRAPH " }\n";
print GRAPH " NET00035\n"; # _RPLY??
print GRAPH " NET00031\n"; # RC-delay
print GRAPH " NET00032\n"; # RTC.DS


print GRAPH "}\n";

}

} # 0000000000
#else
#{
#print GRAPH "OR1 [label=\"{ { <R>R | <A>A } | { OR\\nR24/VD13 } | { <Q>Q } }\"];\n";
#print GRAPH "V3:RF18:e->OR1:A:w\n";
#print GRAPH "V3:O19:e->OR1:R:w\n";
#print GRAPH "OR1:Q:e->NET00064:w\n";
#}

#  print GRAPH "VA\n";
#  print GRAPH "  subgraph cluster_16 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
#  print GRAPH "  MMWM2B\n";
#  print GRAPH "  MMWM4B\n";
#  print GRAPH "  }\n";


#  print GRAPH "  subgraph cluster_24 {rank=\"min\";rankdir=TB;color=blue;label=\"\"\n";
#  print GRAPH "  VU1_Y0\n";
#  print GRAPH "  }\n";


print GRAPH "\n\nlabelloc=b;labeljust=l;label=\"Regs used: $Regs_used\n";
print GRAPH "Z-buffers used: $Zbuf_used\n";
print GRAPH "  Pads used: $Pads_used (input only:$Pads_input, output only:$Pads_output)";
print GRAPH "\"\nfontsize=30;\n}";

#print Dumper %FW;

close INFO;
close TEX;
