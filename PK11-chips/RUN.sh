rm pk11logic-v*.tex

./eqn2tex.pl

dot -Tpdf graph.gv >graph.pdf
dot -Tsvg graph.gv >graph.svg || exit
#dot -Tpng graph.gv >graph.png
#dot -Tps graph.gv >graph.ps

pdfposter -p 2x2a4 graph.pdf graph-2x2a4.pdf

pdflatex pk11logic-v*.tex


#dot -P >formats.gv
#dot -Tpdf formats.gv >formats.pdf