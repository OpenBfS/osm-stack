#!/usr/bin/perl

while(<>)
{
    chomp;
   $i=$_;
   undef $o;
   while ($i =~ /^(.*?)#([0-9a-f]{6})(.*)/i)
   {
       my @rgb = unpack 'C*', pack 'H*', $2;
       my $c = .299*$rgb[0]+.587*$rgb[1]+.114*$rgb[2];
       $o .= $1."#".sprintf("%02x%02x%02x", $c, $c, $c);
       $i=$3;
   }

   $i=$o.$i;
   undef $o;
   while ($i =~ /^(.*rgba?\()(\d+),\s*(\d+),\s*(\d+)(.*)/)
   {
       my $c = .299*$2+.587*$3+.114*$4;
       $o .= sprintf("%s%d,%d,%d", $1, $c, $c, $c);
       $i=$5;
   }
   $o.=$i;

   print "$o\n";
}

