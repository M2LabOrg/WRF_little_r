#!/usr/bin/perl
#
# This utility program convert observation data file in the standard
#   LITTLE_R format to the format that WRF obs-nudging requires.
# Note that:
#   1). P,T,U,V and RH fields are extracted
#   2). U and V are assumed to be the wind components rotated to 
#       the model map-projection (see 3DVAR and MM5 Little_R
#   3). SPD, DIR and Td field are ignored 
#   4). For upper-air data, currently WRF nudging only takes
#       those data with valid pressure records. For obs with 
#       at height levels (e.g. wind profilers data), users need to 
#       calculate or estimate the pressure value. Inaccurate 
#       estimate of pressure will lead to bad data assimilation.  
#
#
#   Input: in-filename (data in little_r format); default filename: all.obs
#   Output: [in-filename].obsnud (data in obs-nudging format)
#
#  Yubao Liu. yliu@ucar.edu, Nov. 2006
#
#########################################################
# Copyright UCAR (c) 1992 - 2006.
# University Corporation for Atmospheric Research (UCAR),
# National Center for Atmospheric Research (NCAR),
# Research Applications Laboratory (RAL),
# P.O.Box 3000, Boulder, Colorado, 80307-3000, USA.
#########################################################
#
#
# block 1: time-space sort the little_r-formated data file
#
$fname = $ARGV[0];
$f_in = $fname; 
$f_in = "all.obs" if( ! $f_in);
$f_out = $f_in.".tmp";

@ALLKK=(); %header=(); %body=(); %tail=();

open (IN, "$f_in");
while($aline = <IN>) {

   $record_start = substr($aline,0,10);
   if ( $record_start == '          ') {
      $lat = substr($aline,10,10);
      $lon = substr($aline,30,10);
      $elev = substr($aline,209,7);
      $nvobs = substr($aline,226,4);
      $issnd = substr($aline,279,1);
      $seqid = substr($aline,256,4);
      $date = substr($aline,326,14);
      $stid = substr($aline,40,5);
      $stna = substr($aline,80,12);
      $fm = substr($aline,120,12);
 
      $kk = $date."#".$lat."#".$lon."#".$elev."#".$issnd ."#".$stid."#".$stna."#".$nvobs."#";
      $tmp="";       
      $header{$kk} = $aline if(length($aline) == 601);
 
      $bline=<IN>;

      $rec_num = 0;
       while ($bline && substr($bline,0,7) ne '-777777') {
          if($issnd eq "T") { 
             $bline =~ s/ 999999/-888888/g;
             $body{$kk} .= $bline;
             $rec_num++;
          } else { 
             $body{$kk} = $bline;  
             $rec_num++;
          }
          $bline=<IN>;
       }

       $cline=<IN>;

       substr($bline,40,7) = sprintf("%7d",$rec_num);
       substr($cline,0,7) = sprintf("%7d",$rec_num);
       substr($header{$kk},226,4) = sprintf("%4d",$rec_num) if($header{$kk});
       $tail{$kk} = $bline.$cline;

       if(substr($bline,40,7) == 0) { delete $header{$kk}; delete $body{$kk};delete $tail{$kk};}
   }
} 

@ALLKEYS = keys %header;


open (ME, ">$f_out");

# $qcoutdate = substr($f_in,7,4).substr($f_in,12,2).substr($f_in,15,2).substr($f_in,18,2);
#print "qcoutdate = $qcoutdate\n";

# foreach $k (sort grep(/$qcoutdate/,@ALLKEYS)) {
 foreach $k (sort @ALLKEYS) {
   print ME $header{$k};
   print ME $body{$k};
   print ME $tail{$k};
 }
 close(ME);close(IN); 

#print "end of block1: rec_num = $rec_num\n";

#
# block 2: reformat the data to obs-nudging format
#

$f_in = $f_out; 
$f_out = $fname.".obsnud";
open (IN, "$f_in");
open (ME, ">$f_out");
$MISSING="-888888";
while($aline = <IN>) {
  $record_start = substr($aline,0,10);
  if ( $record_start == '          ') {
#   print $aline;
   $lat = sprintf("%9.2f",substr($aline,8,10));
   $lon = sprintf("%9.2f",substr($aline,28,10));
   $stid = substr($aline,40,5);
   $stna = substr($aline,45,75);
   $fm = substr($aline,120,18);
   $st_type = substr($aline,160,16);
   $elev = substr($aline,207,8);
   $nlev = substr($aline,226,4);
   $issnd = substr($aline,279,1);
   $isbug = substr($aline,289,1);
   $date = substr($aline,326,14);
   $seqid = substr($aline,256,4);
   $nlev="   1" if($issnd eq "F");
   print ME " $date\n";
   print ME "$lat $lon\n";
   print ME "  $stid   $stna\n";
   print ME "  $fm$st_type  $elev     $issnd     $isbug   $nlev\n";
   if($issnd eq "T") {
      for ($i=0; $i  < $nlev; $i++) {
       $aline = <IN>;
       substr($aline, 0,11)=$MISSING.".000" if(substr($aline,0,13) =~ "nan");
       substr($aline, 13,7)=$MISSING if(substr($aline,  0,11) < -80000.);
       substr($aline, 33,7)=$MISSING if(substr($aline, 20,11) < -80000.);
       substr($aline, 53,7)=$MISSING if(substr($aline, 40,11) < -80000.);
       substr($aline,133,7)=$MISSING if(substr($aline,120,11) < -80000.);
       substr($aline,153,7)=$MISSING if(substr($aline,140,11) < -80000.);
       substr($aline,173,7)=$MISSING if(substr($aline,160,11) < -80000.);
       print ME " ".substr($aline,  0,11)." ".substr($aline, 13,7).".000"
               ." ".substr($aline, 20,11)." ".substr($aline, 33,7).".000" 
               ." ".substr($aline, 40,11)." ".substr($aline, 53,7).".000" 
               ." ".substr($aline,120,11)." ".substr($aline,133,7).".000" 
               ." ".substr($aline,140,11)." ".substr($aline,153,7).".000" 
               ." ".substr($aline,160,11)." ".substr($aline,173,7).".000\n";
      }
   } else {
     $ref_p=" ".$MISSING.".000 ".$MISSING.".000";
     $preci=" ".$MISSING.".000 ".$MISSING.".000";
     $ref_h="       0.000"." "."      0.000";
     $bline=<IN>;
     print $bline if ($bline =~ "nan");
       substr($bline, 0,11)=$MISSING.".000" if(substr($bline,0,13) =~ "nan");
       substr($bline, 53,7)=$MISSING if(substr($bline, 40,11) < -80000.);
       substr($bline,133,7)=$MISSING if(substr($bline,120,11) < -80000.);
       substr($bline,153,7)=$MISSING if(substr($bline,140,11) < -80000.);
       substr($bline,173,7)=$MISSING if(substr($bline,160,11) < -80000.);
       substr($aline,353,7)=$MISSING if(substr($aline,340,11) < -80000.);
       $slp=" ".substr($aline,340,11)." ".substr($aline,353,7).".000";

       print ME $slp.$ref_p.$ref_h
               ." ".substr($bline, 40,11)." ".substr($bline, 53,7).".000"
               ." ".substr($bline,120,11)." ".substr($bline,133,7).".000" 
               ." ".substr($bline,140,11)." ".substr($bline,153,7).".000" 
               ." ".substr($bline,160,11)." ".substr($bline,173,7).".000" 
               ." ".substr($bline,  0,11)." ".substr($bline, 13,7).".000" 
               .$preci."\n";
   }
  }
}
close(IN);close(ME);

